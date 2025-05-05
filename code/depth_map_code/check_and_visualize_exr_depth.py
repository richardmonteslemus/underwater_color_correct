# # For checking if it is a valid exr

# import OpenEXR
# import Imath
# import numpy as np

# def simple_check_exr(file_path):
#     try:
#         # Try opening the EXR file
#         exr_file = OpenEXR.InputFile(file_path)
        
#         # Get basic header information
#         header = exr_file.header()
#         channels = header['channels']
#         print(f"Channels in the EXR file: {channels}")
        
#         # Check if 'unknown 0' or any channel contains depth information
#         depth_channel_name = None
#         for channel_name in channels:
#             if 'depth' in channel_name.lower():  # Look for depth-related channels
#                 depth_channel_name = channel_name
#                 break
        
#         if not depth_channel_name:
#             # If no depth-related channel found, use the first available channel (e.g., 'unknown 0')
#             depth_channel_name = list(channels.keys())[0]
        
#         print(f"Using channel: {depth_channel_name}")
        
#         # Read the selected depth channel
#         depth_channel = exr_file.channel(depth_channel_name)
        
#         # Check if depth data can be loaded properly
#         depth_array = np.frombuffer(depth_channel, dtype=np.float16)  # 'HALF' is 16-bit float
        
#         # Check for NaN or Inf values in the depth map
#         if np.isnan(depth_array).any() or np.isinf(depth_array).any():
#             print("Warning: The depth map contains NaN or Inf values, which suggests corruption.")
#         else:
#             print("Depth map appears valid (no NaN or Inf values).")
        
#         print("EXR file successfully read and basic checks passed.")
    
#     except Exception as e:
#         print(f"Error while processing EXR file: {e}")

# # Path to your EXR file
# file_path = r"C:\Users\colorlab.IUI\Desktop\233A0001.exr"

# # Run the simplified check
# simple_check_exr(file_path)


import OpenEXR
import numpy as np
import matplotlib.pyplot as plt

def visualize_depth_with_colormap(file_path):
    try:
        # Open the EXR file
        exr_file = OpenEXR.InputFile(file_path)
        
        # Read the depth channel (assuming 'unknown 0' for depth, adjust if necessary)
        depth_channel = exr_file.channel('unknown 0')
        depth_array = np.frombuffer(depth_channel, dtype=np.float16)
        
        # Get image dimensions (width, height) using the dataWindow from header
        header = exr_file.header()
        data_window = header['dataWindow']
        width = data_window.max.x - data_window.min.x + 1
        height = data_window.max.y - data_window.min.y + 1
        
        # Reshape the depth data to match the image dimensions
        depth_image = depth_array.reshape((height, width))
        
        # Do NOT normalize the depth values to 0-1. Instead, retain the real values
        # Create the colormap (you can choose different colormaps)
        plt.imshow(depth_image, cmap='viridis', vmin=np.min(depth_image), vmax=np.max(depth_image))
        
        # Add colorbar to show the actual depth scale (real-world units)
        plt.colorbar(label="Depth Value (Meters)")  
        plt.title("EXR Depth Map Visualization IUI Protocol")
        plt.axis('off')  # Hide axis
        plt.show()

    except Exception as e:
        print(f"Error: {e}")

# Path to your EXR file
file_path = r'E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\depth\233A0001.exr'
visualize_depth_with_colormap(file_path)
