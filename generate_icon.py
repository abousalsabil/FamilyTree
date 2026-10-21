import math
from PIL import Image, ImageDraw, ImageFont

def generate_family_circle_icon(size=512, filepath="assets/icons/family_circle_icon.png"):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    center = size / 2
    radius = size * 0.45

    # Outer decorative circle / badge
    draw.ellipse([center - radius, center - radius, center + radius, center + radius], fill="#00897B")

    inner_radius = size * 0.41
    draw.ellipse([center - inner_radius, center - inner_radius, center + inner_radius, center + inner_radius], fill="#E0F2F1")

    # Family members standing in a circle holding hands
    num_members = 6
    circle_radius = size * 0.22
    colors = ["#1E88E5", "#D81B60", "#43A047", "#FB8C00", "#8E24AA", "#00ACC1"]

    member_positions = []
    for i in range(num_members):
        angle = (2 * math.pi / num_members) * i - (math.pi / 2)
        x = center + circle_radius * math.cos(angle)
        y = center + circle_radius * math.sin(angle)
        member_positions.append((x, y, angle))

    # Draw holding hands ring (connecting lines)
    for i in range(num_members):
        x1, y1, _ = member_positions[i]
        x2, y2, _ = member_positions[(i + 1) % num_members]
        draw.line([x1, y1, x2, y2], fill="#00796B", width=int(size * 0.03))

    # Draw members (heads and bodies)
    head_size = size * 0.075
    body_size = size * 0.11

    for i, (x, y, angle) in enumerate(member_positions):
        color = colors[i % len(colors)]

        # Head
        draw.ellipse([x - head_size, y - head_size - size*0.04, x + head_size, y - head_size/2], fill="#FFD54F")
        # Body
        draw.ellipse([x - body_size/2, y - size*0.02, x + body_size/2, y + body_size], fill=color)

    # Save image
    import os
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    img.save(filepath, "PNG")
    print(f"Icon saved to {filepath}")

if __name__ == "__main__":
    generate_family_circle_icon(512, "web/icons/Icon-512.png")
    generate_family_circle_icon(192, "web/icons/Icon-192.png")
    generate_family_circle_icon(192, "web/icons/Icon-maskable-192.png")
    generate_family_circle_icon(512, "web/icons/Icon-maskable-512.png")
    generate_family_circle_icon(64, "web/favicon.png")
    generate_family_circle_icon(512, "assets/icons/family_circle_icon.png")
