
# This script exports a SCALED DENSE depth map as an OpenEXR (.exr) file.
# The depth maps maintain the same resolution as the original images in the chunk.
# Script modified from the original version by Derya Akkaynak.
# Updated to export as EXR by Richie.

# import Metashape
# import sys
# import os

# # Output path is read from 'Arguments' dialogue in Metashape
# path = sys.argv[1]

# # Select active chunk
# chunk = Metashape.app.document.chunk

# # Check if the model is scaled, otherwise assign scale of 1
# scale = chunk.transform.scale if chunk.transform.scale is not None else 1

# # Export depth maps for all aligned cameras in chunk
# for camera in chunk.cameras:
#     # Ensure the camera is aligned before exporting
#     if camera.transform:
#         depth = chunk.model.renderDepth(camera.transform, camera.sensor.calibration)
#         depth = depth * scale  # Apply scale factor
#         depth = depth.convert(" ", "F16")  # Convert to 16-bit float for EXR

#         # Save depth map as EXR (without explicit compression settings)
#         depth.save(path + os.sep + camera.label + ".exr")

# print("Depth maps exported as EXR successfully.")
# # 

# This script exports a SCALED DENSE depth map as an OpenEXR (.exr) file.
# The depth maps maintain the same resolution as the original images in the chunk.
# Script modified from the original version by Derya Akkaynak.
# Updated to export as EXR by Richie.



# import Metashape
# import sys
# import os

# # Output path is read from 'Arguments' dialogue in Metashape
# path = sys.argv[1]

# # Select active chunk
# chunk = Metashape.app.document.chunk 

# # Check if the model is scaled, otherwise assign scale of 1
# scale = chunk.transform.scale if chunk.transform.scale is not None else 1

# # Export depth maps for all aligned cameras in chunk
# for camera in chunk.cameras:
#     # Ensure the camera is aligned before exporting
#     if camera.transform:
#         depth = chunk.model.renderDepth(camera.transform, camera.sensor.calibration)
#         depth = depth * scale  # Apply scale factor
#         depth = depth.convert(" ", "F16")  # Convert to 16-bit float for EXR
        
#         # Save depth map as EXR (without explicit compression settings)
#         depth.save(path + os.sep + camera.label + ".exr")
#         # depth.save(path + os.sep + camera.label + ".exr", compression="ZIP", channels=["R", "G", "B"])


#print("Depth maps exported as EXR successfully.")


# import Metashape
# import sys
# import os

# # Output path is read from 'Arguments' dialogue in Metashape
# path = sys.argv[1]

# # Select active chunk
# chunk = Metashape.app.document.chunk 

# # Check if the model is scaled, otherwise assign scale of 1
# scale = chunk.transform.scale if chunk.transform.scale is not None else 1

# # Export depth maps for all aligned cameras in chunk
# for camera in chunk.cameras:
#     # Ensure the camera is aligned before exporting
#     if camera.transform:
#         depth = chunk.model.renderDepth(camera.transform, camera.sensor.calibration)
#         depth = depth * scale  # Apply scale factor
#         depth = depth.convert(" ", "F16")  # Convert to 16-bit float for EXR
        
#         # Save depth map as EXR (without explicit compression settings)
#         depth.save(path + os.sep + camera.label + ".exr")
#         # depth.save(path + os.sep + camera.label + ".exr", compression="ZIP", channels=["R", "G", "B"])


# print("Depth maps exported as EXR successfully.")

 

# def save_exr(filename, image):

#     """Save a float32 numpy array as an EXR file"""

#     height, width = image.shape

#     header = OpenEXR.Header(width, height)

#     header['channels'] = {'R': Imath.Channel(Imath.PixelType(Imath.PixelType.FLOAT))}

   

#     exr = OpenEXR.OutputFile(filename, header)

#     exr.writePixels({'R': image.astype(np.float32).tobytes()})

#     exr.close()

 

# # Example usage

# image = np.random.rand(512, 512).astype(np.float32)  # Example image

# save_exr("test.exr", image)



import Metashape
import sys
import os
import OpenEXR
import Imath
import numpy as np

# Output path is read from 'Arguments' dialogue in Metashape
path = sys.argv[1]

# Select active chunk
chunk = Metashape.app.document.chunk 

# Check if the model is scaled, otherwise assign scale of 1
scale = chunk.transform.scale if chunk.transform.scale is not None else 1

def save_exr(filename, image):
    """Save a float32 numpy array as an EXR file with proper headers."""
    height, width = image.shape

    # Define the EXR header with a single R channel
    header = OpenEXR.Header(width, height)
    header['channels'] = {'R': Imath.Channel(Imath.PixelType(Imath.PixelType.FLOAT))}

    # Create EXR file with header
    exr = OpenEXR.OutputFile(filename, header)

    # Convert image data to bytes and write to EXR
    exr.writePixels({'R': image.astype(np.float32).tobytes()})
    exr.close()

# Export depth maps for all aligned cameras in chunk
for camera in chunk.cameras:
    # Ensure the camera is aligned before exporting
    if camera.transform:
        depth = chunk.model.renderDepth(camera.transform, camera.sensor.calibration)
        depth = depth * scale  # Apply scale factor
        depth = depth.convert(" ", "F32")  # Convert to 32-bit float for EXR

        # Convert Metashape image to NumPy array
        depth_data = np.array(depth)  # Assuming Metashape output can be converted to NumPy array

        # Save depth map as EXR with proper headers
        save_exr(os.path.join(path, camera.label + ".exr"), depth_data)

print("Depth maps exported as EXR successfully with headers.")
