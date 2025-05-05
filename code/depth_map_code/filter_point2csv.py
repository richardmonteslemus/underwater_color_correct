
import Metashape
import csv
import os
import sys

# Output path is read from 'Arguments' Dialogue in Metashape
output_dir = sys.argv[1]
output_csv = os.path.join(output_dir, "selected_color_charts.csv")

# Get the current Metashape project and chunk
doc = Metashape.app.document
chunk = doc.chunk

# Get selected image names
selected_images = {camera.label for camera in chunk.cameras if camera.selected}

if selected_images:
    existing_data = []
    header = ["FileName", "ColorChartNumber"]
    file_exists = os.path.exists(output_csv)
    
    # Read existing CSV if it exists
    if file_exists:
        with open(output_csv, mode="r", newline="") as file:
            reader = csv.reader(file)
            rows = list(reader)
            if rows:
                header = rows[0]  # Preserve header
                existing_data = rows[1:]
    
    # Convert existing data to a dictionary for quick lookup
    existing_dict = {row[0]: int(row[1]) for row in existing_data if row}
    
    # Determine new batch number
    current_batch_number = max(existing_dict.values(), default=0) + 1
    
    new_rows = []
    for image in selected_images:
        if image not in existing_dict:
            new_rows.append([image, current_batch_number])
    
    # Append new batch data
    existing_data.extend(new_rows)
    
    # Write back updated data
    with open(output_csv, mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(header)
        writer.writerows(existing_data)
    
    print(f"Updated {output_csv} with batch {current_batch_number} of newly selected images.")
else:
    print("No images selected.")
