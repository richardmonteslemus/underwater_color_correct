# import Metashape
# import sys
# import os
# import csv

# # Output CSV file path is read from 'Arguments' Dialogue in Metashape
# csv_path = sys.argv[1]  # This is where the CSV file will be saved

# # Initialize the document and chunk
# doc = Metashape.app.document
# chunk = doc.chunk

# # Prepare the list to hold filtered image file names
# filtered_cameras = set()

# # Iterate through the point cloud and collect the cameras for filtered points
# for point in chunk.point_cloud.points:
#     if point.selected:  # Check if the point is selected (filtered)
#         for track in point.tracks:
#             camera = chunk.cameras[track.key]
#             if camera.enabled:
#                 filtered_cameras.add(camera.label)

# # Define the CSV file name based on the path given in the argument
# csv_file_name = os.path.join(csv_path, "filtered_image_file_names.csv")

# # Write the collected image names to the CSV file
# with open(csv_file_name, mode='w', newline='') as file:
#     writer = csv.writer(file)
#     writer.writerow(["Image File Name"])  # Column header
#     for camera in filtered_cameras:
#         writer.writerow([camera])  # Write each camera name as a row

# # Confirm the file is saved
# print(f"File saved as: {csv_file_name}")

# import Metashape
# import csv
# import os

# doc = Metashape.app.document
# chunk = doc.chunk

# output_csv = "E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\img_csv_files\dng_color_charts.csv"  # Change this to your file path
# new_column_name = "Selected Images"  # Name of the new column

# # Get selected image names
# selected_images = [camera.label for camera in chunk.cameras if camera.selected]

# if selected_images:
#     # Read existing CSV data
#     existing_data = []
#     if os.path.exists(output_csv):
#         with open(output_csv, mode="r", newline="") as file:
#             reader = csv.reader(file)
#             existing_data = [row for row in reader]
    
#     # Add new column header if needed
#     if existing_data and new_column_name not in existing_data[0]:
#         existing_data[0].append(new_column_name)

#     # Add selected images to a new column (aligning with existing rows or adding new ones)
#     max_rows = max(len(existing_data) - 1, len(selected_images))
#     for i in range(max_rows):
#         if i + 1 < len(existing_data):  # Existing row
#             existing_data[i + 1].append(selected_images[i] if i < len(selected_images) else "")
#         else:  # New row
#             existing_data.append([""] * (len(existing_data[0]) - 1) + [selected_images[i]])

#     # Write back the modified data
#     with open(output_csv, mode="w", newline="") as file:
#         writer = csv.writer(file)
#         writer.writerows(existing_data)

#     print(f"Selected images added as a new column in: {output_csv}")
# else:
#     print("No images selected.")

import Metashape
import csv
import os

doc = Metashape.app.document
chunk = doc.chunk

output_csv = "E:/Colorimetry/Photos/Coiba/Canales_15_January_2024/Canales_15_January_2024_0to25/dng_creation/img_csv_files/dng_color_charts.csv"
new_column_name = "Selected Images"

# Get selected image names
selected_images = {camera.label: camera.label for camera in chunk.cameras if camera.selected}  # Use dictionary for lookup

if selected_images:
    existing_data = []
    
    # Read existing CSV
    if os.path.exists(output_csv):
        with open(output_csv, mode="r", newline="") as file:
            reader = csv.reader(file)
            existing_data = [row for row in reader]

    # Ensure header exists
    if existing_data and new_column_name not in existing_data[0]:
        existing_data[0].append(new_column_name)

    # Find column indexes
    header = existing_data[0]
    filename_idx = header.index("FileName")  # Find the index of "FileName"
    
    # Update rows with matched images
    for row in existing_data[1:]:  # Skip header
        file_name = row[filename_idx].split(".")[0]  # Remove extension for matching
        row.append(selected_images.get(file_name, ""))  # Add matching image or empty string

    # Write back to CSV
    with open(output_csv, mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerows(existing_data)

    print(f"Selected images matched to corresponding filenames in: {output_csv}")
else:
    print("No images selected.")
