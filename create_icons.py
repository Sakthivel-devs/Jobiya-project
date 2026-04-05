import base64
import io
from PIL import Image, ImageDraw
import math

def create_icon(size):
    """Create a circular icon with bacterial theme"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Colors
    bg_color = (0, 245, 196, 255)  # #00f5c4
    accent_color = (255, 107, 107, 255)  # #ff6b6b

    # Draw background circle
    center = size // 2
    radius = size // 2 - 2
    draw.ellipse([2, 2, size-2, size-2], fill=bg_color)

    # Draw bacterial growth pattern (simplified)
    # Draw some curved lines representing growth curves
    for i in range(3):
        angle = (i * 120) * math.pi / 180
        x1 = center + int(radius * 0.3 * math.cos(angle))
        y1 = center + int(radius * 0.3 * math.sin(angle))
        x2 = center + int(radius * 0.8 * math.cos(angle + 0.5))
        y2 = center + int(radius * 0.8 * math.sin(angle + 0.5))

        # Draw growth curve
        draw.line([x1, y1, x2, y2], fill=accent_color, width=max(1, size//32))

    # Draw center dot
    dot_size = max(2, size//16)
    draw.ellipse([center-dot_size, center-dot_size, center+dot_size, center+dot_size], fill=accent_color)

    return img

def save_icon(size, filename):
    """Create and save icon"""
    icon = create_icon(size)
    icon.save(filename, 'PNG')
    print(f"Created {filename}")

# Create icons
save_icon(192, 'f:\\New folder\\static\\icon-192.png')
save_icon(512, 'f:\\New folder\\static\\icon-512.png')

# Create a simple screenshot placeholder
screenshot = Image.new('RGB', (390, 844), (6, 9, 15))  # Dark background
draw = ImageDraw.Draw(screenshot)
draw.text((195, 422), 'Bacterial\nAnalyzer\nScreenshot', fill=(0, 245, 196), anchor='mm')
screenshot.save('f:\\New folder\\static\\screenshot-mobile.png', 'PNG')

print("Icons created successfully!")