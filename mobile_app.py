import sys
import os
from flask import Flask, send_from_directory, jsonify, request
from flask_cors import CORS

# Import the main app
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from app import app as main_app

# Create mobile app
mobile_app = Flask(__name__, static_folder='../static')
CORS(mobile_app)

@mobile_app.route('/')
def index():
    return send_from_directory('../templates', 'index.html')

@mobile_app.route('/static/<path:filename>')
def static_files(filename):
    return send_from_directory('../static', filename)

# Proxy all API routes to main app
@mobile_app.route('/api/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
def api_proxy(path):
    # Create a test request context for the main app
    with main_app.test_request_context(
        request.path,
        method=request.method,
        data=request.get_data(),
        headers=dict(request.headers)
    ):
        # Copy query parameters
        for key, value in request.args.items():
            main_app.test_request_context().request.args = request.args

        try:
            response = main_app.full_dispatch_request()
            return response
        except Exception as e:
            return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # For Capacitor development
    mobile_app.run(host='0.0.0.0', port=5000, debug=False)