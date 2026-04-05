from flask import Flask, render_template, request, jsonify, send_file
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import plotly.graph_objects as go
import plotly.utils
import json
import io
import base64
from scipy.optimize import curve_fit
from sklearn.cluster import KMeans
import os
from datetime import datetime

app = Flask(__name__)

# Sample data for demonstration
def generate_sample_data():
    """Generate sample bacterial growth data"""
    time = np.linspace(0, 24, 50)  # 24 hours
    # Simulate different growth conditions
    conditions = ['Control', 'Treatment A', 'Treatment B', 'Treatment C']

    data = {}
    for condition in conditions:
        # Logistic growth model
        L = np.random.uniform(1.5, 2.5)  # carrying capacity
        k = np.random.uniform(0.3, 0.8)  # growth rate
        x0 = np.random.uniform(0.01, 0.05)  # initial value

        od600 = L / (1 + (L/x0 - 1) * np.exp(-k * time))
        # Add some noise
        noise = np.random.normal(0, 0.02, len(od600))
        od600 += noise
        od600 = np.maximum(od600, 0)  # ensure non-negative

        data[condition] = {
            'time': time.tolist(),
            'od600': od600.tolist()
        }

    return data

# Global data storage (in production, use a database)
app_data = {
    'current_data': generate_sample_data(),
    'sessions': {},
    'alerts': []
}

def logistic_growth(t, L, k, x0):
    """Logistic growth model"""
    return L / (1 + (L/x0 - 1) * np.exp(-k * t))

def fit_growth_curve(time, od600):
    """Fit logistic growth curve to data"""
    try:
        od600 = np.asarray(od600)
        time = np.asarray(time)
        
        # Initial estimates
        max_od = float(np.max(od600))
        positive_mask = od600 > 0.001
        min_positive = float(np.min(od600[positive_mask])) if np.any(positive_mask) else 0.01
        
        p0 = [max_od, 0.5, min_positive]
        
        # Fit curve
        popt, pcov = curve_fit(logistic_growth, time, od600, p0=p0, maxfev=5000)
        return popt
    except Exception as e:
        return None

def calculate_growth_parameters(time, od600):
    """Calculate growth kinetics parameters"""
    params = fit_growth_curve(time, od600)
    if params is None:
        return None

    L, k, x0 = params

    # Calculate additional parameters
    lag_time = -np.log((L/x0 - 1)) / k if x0 > 0 else 0
    doubling_time = np.log(2) / k

    return {
        'carrying_capacity': L,
        'growth_rate': k,
        'initial_od': x0,
        'lag_time': lag_time,
        'doubling_time': doubling_time
    }

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/data')
def get_data():
    return jsonify(app_data['current_data'])

@app.route('/api/chart/<chart_type>')
def get_chart(chart_type):
    data = app_data['current_data']
    
    # Extract toolbar options from query parameters
    options = {
        'show_phases': request.args.get('phases', 'true').lower() == 'true',
        'log_scale': request.args.get('log_scale', 'false').lower() == 'true',
        'show_errors': request.args.get('errors', 'false').lower() == 'true',
        'show_fit': request.args.get('fit', 'true').lower() == 'true',
        'show_predict': request.args.get('predict', 'true').lower() == 'true',
    }

    if chart_type == 'growth':
        return create_growth_chart(data, options)
    elif chart_type == 'heatmap':
        return create_heatmap(data)
    elif chart_type == 'radar':
        return create_radar_chart(data)
    elif chart_type == 'science':
        return create_science_chart(data)
    else:
        return jsonify({'error': 'Unknown chart type'})

def create_growth_chart(data, options=None):
    """Create growth curve chart with optional features"""
    if options is None:
        options = {'show_phases': True, 'log_scale': False, 'show_errors': False, 'show_fit': True, 'show_predict': False}
    
    fig, ax = plt.subplots(figsize=(12, 7))
    colors = ['#00f5c4', '#ff6b6b', '#ffd93d', '#c084fc']
    
    # Calculate max time for predictions
    all_times = [np.max(values['time']) for values in data.values()]
    max_time = np.max(all_times) if all_times else 24
    predict_time = np.linspace(0, max_time * 1.3, 150) if options.get('show_predict') else None

    for i, (condition, values) in enumerate(data.items()):
        time = np.asarray(values['time'])
        od600 = np.asarray(values['od600'])
        color = colors[i % len(colors)]

        # Plot actual data points
        ax.plot(time, od600, 'o-', color=color, label=condition,
                markersize=5, linewidth=2.5, alpha=0.8)

        # Calculate and display error (standard deviation over 3-point windows)
        if options.get('show_errors', False):
            errors = []
            for j in range(len(time)):
                window = od600[max(0, j-1):min(len(od600), j+2)]
                errors.append(np.std(window))
            errors = np.array(errors)
            ax.fill_between(time, od600 - errors, od600 + errors, color=color, alpha=0.15)

        # Fit and plot growth curve
        params = fit_growth_curve(time, od600)
        if params is not None:
            L, k, x0 = params
            
            if options.get('show_fit', True):
                # Fitted curve on observed region
                t_fit = np.linspace(min(time), max(time), 100)
                od_fit = logistic_growth(t_fit, L, k, x0)
                ax.plot(t_fit, od_fit, '--', color=color, alpha=0.7, linewidth=2, label=f'{condition} (fit)')
            
            # Prediction beyond observed data
            if options.get('show_predict', False) and predict_time is not None:
                od_predict = logistic_growth(predict_time, L, k, x0)
                ax.plot(predict_time, od_predict, ':', color=color, alpha=0.5, linewidth=2.5)
                
                # Mark growth phases if enabled
                if options.get('show_phases', True):
                    # Find phase transitions (lag, exponential, stationary)
                    lag_end = x0 * np.exp(2 / k)
                    stationary_start = L * 0.95
                    
                    # Lag phase
                    ax.axhspan(0, lag_end, alpha=0.05, color='blue', zorder=0)
                    # Stationary phase (if reached)
                    if np.max(od600) > stationary_start:
                        ax.axhspan(stationary_start, L * 1.05, alpha=0.05, color='green', zorder=0)
    
    # Add phase legend if showing phases
    if options.get('show_phases', True) and options.get('show_predict', False):
        from matplotlib.patches import Patch
        legend_elements = [
            Patch(facecolor='blue', alpha=0.1, label='Lag Phase'),
            Patch(facecolor='yellow', alpha=0.1, label='Exponential Phase'),
            Patch(facecolor='green', alpha=0.1, label='Stationary Phase')
        ]
        ax.legend(handles=legend_elements, loc='upper left', fontsize=8)
    else:
        ax.legend(fontsize=9, loc='upper left')

    ax.set_xlabel('Time (hours)', fontsize=11)
    
    if options.get('log_scale', False):
        ax.set_ylabel('OD₆₀₀ (log scale)', fontsize=11)
        ax.set_yscale('log')
    else:
        ax.set_ylabel('OD₆₀₀', fontsize=11)
    
    title = 'Bacterial Growth Curves'
    if options.get('show_predict', False):
        title += ' (with predictions)'
    if options.get('log_scale', False):
        title += ' [Log Scale]'
    ax.set_title(title, fontsize=12, fontweight='bold')
    
    ax.grid(True, alpha=0.3)

    # Convert to base64
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=100, bbox_inches='tight')
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)

    return jsonify({'chart': f'data:image/png;base64,{img_base64}'})

def create_heatmap(data):
    """Create heatmap visualization"""
    conditions = list(data.keys())
    time_points = data[conditions[0]]['time']

    # Create OD600 matrix
    od_matrix = []
    for condition in conditions:
        od_matrix.append(data[condition]['od600'])

    od_matrix = np.array(od_matrix)

    fig, ax = plt.subplots(figsize=(10, 6))
    im = ax.imshow(od_matrix, aspect='auto', cmap='viridis')

    ax.set_xticks(range(0, len(time_points), 5))
    ax.set_xticklabels([f'{t:.1f}' for t in time_points[::5]])
    ax.set_yticks(range(len(conditions)))
    ax.set_yticklabels(conditions)

    ax.set_xlabel('Time (hours)')
    ax.set_ylabel('Conditions')
    ax.set_title('Growth Heatmap')

    plt.colorbar(im, ax=ax, label='OD₆₀₀')

    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=100, bbox_inches='tight')
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)

    return jsonify({'chart': f'data:image/png;base64,{img_base64}'})

def create_radar_chart(data):
    """Create radar chart for growth parameters"""
    conditions = list(data.keys())
    parameters = ['Max OD', 'Growth Rate', 'Area Under Curve']

    # Calculate parameters for each condition
    param_data = {}
    for condition in conditions:
        time = np.array(data[condition]['time'])
        od600 = np.array(data[condition]['od600'])

        max_od = np.max(od600)
        growth_params = calculate_growth_parameters(time, od600)
        growth_rate = growth_params['growth_rate'] if growth_params is not None else 0
        auc = np.trapz(od600, time)

        param_data[condition] = [float(max_od), float(growth_rate), float(auc)]

    # Normalize data for radar chart
    normalized_data = {}
    for param_idx, param in enumerate(parameters):
        values = [param_data[cond][param_idx] for cond in conditions]
        max_val = max(values) if values else 1
        for cond in conditions:
            if cond not in normalized_data:
                normalized_data[cond] = []
            normalized_data[cond].append(param_data[cond][param_idx] / max_val if max_val > 0 else 0)

    # Create radar chart using matplotlib
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='polar')
    
    angles = np.linspace(0, 2*np.pi, len(parameters), endpoint=False).tolist()
    angles += angles[:1]  # Complete the circle
    
    colors = ['#00f5c4', '#ff6b6b', '#ffd93d', '#c084fc']
    
    for idx, (condition, values) in enumerate(normalized_data.items()):
        values_plot = values + [values[0]]  # Complete the circle
        ax.plot(angles, values_plot, 'o-', linewidth=2, label=condition, color=colors[idx % len(colors)])
        ax.fill(angles, values_plot, alpha=0.15, color=colors[idx % len(colors)])
    
    ax.set_xticks(angles[:-1])
    ax.set_xticklabels(parameters)
    ax.set_ylim(0, 1)
    ax.set_title('Growth Parameters Comparison', fontsize=12, fontweight='bold', pad=20)
    ax.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1))
    ax.grid(True)
    
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=100, bbox_inches='tight')
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)

    return jsonify({'chart': f'data:image/png;base64,{img_base64}'})

def create_science_chart(data):
    """Create scientific analysis summary chart"""
    conditions = list(data.keys())
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Scientific Analysis Summary', fontsize=14, fontweight='bold')
    
    # Extract parameters for all conditions
    carrying_capacities = []
    growth_rates = []
    lag_times = []
    doubling_times = []
    
    for condition in conditions:
        time = np.array(data[condition]['time'])
        od600 = np.array(data[condition]['od600'])
        params = calculate_growth_parameters(time, od600)
        
        if params:
            carrying_capacities.append(params['carrying_capacity'])
            growth_rates.append(params['growth_rate'])
            lag_times.append(max(0, params['lag_time']))
            doubling_times.append(params['doubling_time'])
        else:
            carrying_capacities.append(0)
            growth_rates.append(0)
            lag_times.append(0)
            doubling_times.append(0)
    
    colors = ['#00f5c4', '#ff6b6b', '#ffd93d', '#c084fc']
    
    # Plot 1: Carrying Capacity
    axes[0, 0].bar(conditions, carrying_capacities, color=colors[:len(conditions)])
    axes[0, 0].set_title('Carrying Capacity (L)', fontweight='bold')
    axes[0, 0].set_ylabel('OD600')
    axes[0, 0].grid(True, alpha=0.3)
    
    # Plot 2: Growth Rate
    axes[0, 1].bar(conditions, growth_rates, color=colors[:len(conditions)])
    axes[0, 1].set_title('Growth Rate (k)', fontweight='bold')
    axes[0, 1].set_ylabel('h-1')
    axes[0, 1].grid(True, alpha=0.3)
    
    # Plot 3: Lag Time
    axes[1, 0].bar(conditions, lag_times, color=colors[:len(conditions)])
    axes[1, 0].set_title('Lag Time', fontweight='bold')
    axes[1, 0].set_ylabel('Hours')
    axes[1, 0].grid(True, alpha=0.3)
    
    # Plot 4: Doubling Time
    axes[1, 1].bar(conditions, doubling_times, color=colors[:len(conditions)])
    axes[1, 1].set_title('Doubling Time', fontweight='bold')
    axes[1, 1].set_ylabel('Hours')
    axes[1, 1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=100, bbox_inches='tight')
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)

    return jsonify({'chart': f'data:image/png;base64,{img_base64}'})

@app.route('/api/analyze/<condition>')
def analyze_condition(condition):
    """Analyze specific growth condition"""
    if condition not in app_data['current_data']:
        return jsonify({'error': 'Condition not found'})

    time = np.array(app_data['current_data'][condition]['time'])
    od600 = np.array(app_data['current_data'][condition]['od600'])

    params = calculate_growth_parameters(time, od600)

    if params:
        analysis = {
            'condition': condition,
            'parameters': {
                'carrying_capacity': round(params['carrying_capacity'], 3),
                'growth_rate': round(params['growth_rate'], 3),
                'initial_od': round(params['initial_od'], 3),
                'lag_time': round(params['lag_time'], 2),
                'doubling_time': round(params['doubling_time'], 2)
            },
            'insights': generate_insights(params)
        }
    else:
        analysis = {
            'condition': condition,
            'error': 'Could not fit growth curve'
        }

    return jsonify(analysis)

def generate_insights(params):
    """Generate AI-like insights from growth parameters"""
    insights = []

    if params['growth_rate'] > 0.6:
        insights.append("High growth rate indicates optimal conditions")
    elif params['growth_rate'] < 0.3:
        insights.append("Low growth rate may indicate stress or suboptimal conditions")

    if params['lag_time'] > 2:
        insights.append("Extended lag phase suggests adaptation period")
    elif params['lag_time'] < 0.5:
        insights.append("Short lag phase indicates good starting conditions")

    if params['carrying_capacity'] > 2:
        insights.append("High carrying capacity suggests nutrient-rich environment")

    return insights

@app.route('/api/upload', methods=['POST'])
def upload_csv():
    """Handle CSV file upload"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'})

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'})

    try:
        df = pd.read_csv(file)
        # Process CSV data and update app_data
        # This is a simplified version - in production, validate data structure
        processed_data = process_csv_data(df)
        app_data['current_data'] = processed_data
        return jsonify({'success': True, 'message': 'Data uploaded successfully'})
    except Exception as e:
        return jsonify({'error': str(e)})

def process_csv_data(df):
    """Process uploaded CSV data"""
    # Assume CSV has columns: time, condition1, condition2, etc.
    time_col = df.columns[0]  # First column is time
    time = df[time_col].values

    data = {}
    for col in df.columns[1:]:  # Skip time column
        data[col] = {
            'time': time.tolist(),
            'od600': df[col].values.tolist()
        }

    return data

@app.route('/api/export/<format>')
def export_data(format):
    """Export data in various formats"""
    data = app_data['current_data']

    if format == 'csv':
        # Create CSV from data
        csv_data = "Time"
        conditions = list(data.keys())
        for condition in conditions:
            csv_data += f",{condition}"
        csv_data += "\n"

        time_points = data[conditions[0]]['time']
        for i, t in enumerate(time_points):
            csv_data += f"{t}"
            for condition in conditions:
                csv_data += f",{data[condition]['od600'][i]}"
            csv_data += "\n"

        return send_file(
            io.BytesIO(csv_data.encode()),
            mimetype='text/csv',
            as_attachment=True,
            download_name='growth_data.csv'
        )

    return jsonify({'error': 'Unsupported format'})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=False, host='0.0.0.0', port=port)