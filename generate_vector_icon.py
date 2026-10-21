import math
from PIL import Image, ImageDraw, ImageFilter

def create_vector_family_icon(size=1024):
    # Supersampling factor for smooth vector look
    scale = 2
    dim = size * scale
    img = Image.new("RGBA", (dim, dim), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    center = dim / 2
    radius = dim * 0.46

    # 1. Soft Outer Glow / Shadow
    shadow = Image.new("RGBA", (dim, dim), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow)
    s_draw.ellipse([center - radius, center - radius, center + radius, center + radius], fill=(0, 0, 0, 80))
    shadow = shadow.filter(ImageFilter.GaussianBlur(dim * 0.02))
    img.paste(shadow, (0, 0), shadow)

    # 2. Outer Ring Gradient (Teal / Emerald Gold Theme)
    draw.ellipse([center - radius, center - radius, center + radius, center + radius], fill="#004D40")

    r_inner1 = dim * 0.43
    draw.ellipse([center - r_inner1, center - r_inner1, center + r_inner1, center + r_inner1], fill="#00897B")

    r_inner2 = dim * 0.415
    draw.ellipse([center - r_inner2, center - r_inner2, center + r_inner2, center + r_inner2], fill="#E0F2F1")

    # 3. Family Ring (Holding Hands Circle)
    num_members = 7
    circle_r = dim * 0.23

    # Member colors (Vibrant modern pastel palette)
    colors = [
        ("#1976D2", "#BBDEFB"), # Male Blue
        ("#E91E63", "#F8BBD0"), # Female Pink
        ("#388E3C", "#C8E6C9"), # Green
        ("#F57C00", "#FFE0B2"), # Orange
        ("#7B1FA2", "#E1BEE7"), # Purple
        ("#0097A7", "#B2EBF2"), # Cyan
        ("#D32F2F", "#FFCDD2"), # Red
    ]

    positions = []
    for i in range(num_members):
        angle = (2 * math.pi / num_members) * i - (math.pi / 2)
        x = center + circle_r * math.cos(angle)
        y = center + circle_r * math.sin(angle)
        positions.append((x, y, angle))

    # Connected Arms Ring (Smooth Thick Curve)
    arm_radius = circle_r
    draw.ellipse(
        [center - arm_radius, center - arm_radius, center + arm_radius, center + arm_radius],
        outline="#00796B",
        width=int(dim * 0.028)
    )

    # Center Family Tree Emblem / Sun
    sun_r = dim * 0.09
    draw.ellipse([center - sun_r, center - sun_r, center + sun_r, center + sun_r], fill="#FFD54F")
    # Tree trunk in center
    draw.rectangle([center - dim*0.012, center - dim*0.03, center + dim*0.012, center + dim*0.06], fill="#795548")
    # Tree canopy
    draw.ellipse([center - dim*0.045, center - dim*0.07, center + dim*0.045, center - dim*0.01], fill="#4CAF50")

    # Draw Family Members
    head_r = dim * 0.05
    body_rx = dim * 0.045
    body_ry = dim * 0.07

    for i, (x, y, angle) in enumerate(positions):
        primary_color, light_color = colors[i % len(colors)]

        # Body (Rounded Capsule / Oval)
        draw.ellipse([x - body_rx, y - body_ry * 0.3, x + body_rx, y + body_ry * 1.1], fill=primary_color)

        # Head (Circle with Skin Tone & Hair/Headband)
        draw.ellipse([x - head_r, y - head_r * 1.7, x + head_r, y + head_r * 0.3], fill="#FFCC80")

        # Hair/Cap Top Accent
        draw.chord([x - head_r*0.95, y - head_r*1.8, x + head_r*0.95, y - head_r*0.7], start=180, end=360, fill=primary_color)

        # Sparkle/Star Hand Joint
        next_x, next_y, _ = positions[(i + 1) % num_members]
        mid_x = (x + next_x) / 2
        mid_y = (y + next_y) / 2
        star_r = dim * 0.015
        draw.ellipse([mid_x - star_r, mid_y - star_r, mid_x + star_r, mid_y + star_r], fill="#FFF9C4")

    # Downsample for Anti-Aliased Smooth Vector Output
    final_img = img.resize((size, size), resample=Image.LANCZOS)
    return final_img

def generate_all():
    icon_1024 = create_vector_family_icon(1024)
    icon_1024.save("assets/icons/family_circle_icon.png")

    icon_512 = create_vector_family_icon(512)
    icon_512.save("web/icons/Icon-512.png")
    icon_512.save("web/icons/Icon-maskable-512.png")

    icon_192 = create_vector_family_icon(192)
    icon_192.save("web/icons/Icon-192.png")
    icon_192.save("web/icons/Icon-maskable-192.png")
    icon_192.save("android/app/src/main/res/mipmap-hdpi/ic_launcher.png")
    icon_192.save("android/app/src/main/res/mipmap-mdpi/ic_launcher.png")
    icon_192.save("android/app/src/main/res/mipmap-xhdpi/ic_launcher.png")
    icon_192.save("android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png")
    icon_192.save("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png")

    icon_64 = create_vector_family_icon(64)
    icon_64.save("web/favicon.png")
    print("All vector-styled icons successfully generated!")

if __name__ == "__main__":
    generate_all()
