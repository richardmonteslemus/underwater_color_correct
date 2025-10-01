import Metashape

def process_chunk(chunk, percentage_to_filter):
    # Align photos with specified settings
    chunk.matchPhotos(downscale=1, generic_preselection=True, reference_preselection=True,
                      reference_preselection_mode=Metashape.ReferencePreselectionSequential,
                      filter_mask=False, mask_tiepoints=False, filter_stationary_points=True,
                      keypoint_limit=40000, keypoint_limit_per_mpx=1000, tiepoint_limit=4000,
                      guided_matching=False)
    chunk.alignCameras(adaptive_fitting=True)

    # Filter tie points based on reconstruction uncertainty
    filter_obj = Metashape.TiePoints.Filter()
    filter_obj.init(chunk, criterion=Metashape.TiePoints.Filter.ReconstructionUncertainty)
    threshold = percentage_to_filter / 100.0 * filter_obj.max_value
    filter_obj.selectPoints(threshold)
    filter_obj.removePoints(threshold)
    filter_obj.resetSelection()

    # Filter tie points based on reprojection error
    filter_obj.init(chunk, criterion=Metashape.TiePoints.Filter.ReprojectionError)
    threshold = percentage_to_filter / 100.0 * filter_obj.max_value
    filter_obj.selectPoints(threshold)
    filter_obj.removePoints(threshold)
    filter_obj.resetSelection()

    chunk.optimizeCameras(fit_f=False, fit_cx=False, fit_cy=False, fit_k1=False, fit_k2=False,
                          fit_k3=False, fit_p1=False, fit_p2=False, adaptive_fitting=True)

    # Build a mesh from depth maps
    chunk.buildDepthMaps(downscale=2)
    chunk.buildModel(surface_type=Metashape.Arbitrary, interpolation=Metashape.EnabledInterpolation,
                     face_count=Metashape.LowFaceCount, source_data=Metashape.DepthMapsData,
                     vertex_colors=False, volumetric_masks=False)

    # Build texture
    chunk.buildUV()
    chunk.buildTexture(blending_mode=Metashape.MosaicBlending, ghosting_filter=False)

# Function to process all chunks in the document
def process_all_chunks():
    percentage_to_filter = Metashape.app.getFloat("Enter the filter for point removal, \n this is the percent of points you keep based on Reprojection error and reconstruction uncertainty", 85)
    # Iterate through all chunks in the document
    for chunk in Metashape.app.document.chunks:
        process_chunk(chunk, percentage_to_filter)

# Function to create a new chunk and add photos
def create_chunk_and_add_photos():
    # Ask the user to select images from a folder
    image_files = Metashape.app.getOpenFileNames("Select Image Files")

    # Create a new chunk and add selected images
    chunk = Metashape.app.document.addChunk()
    chunk.addPhotos(image_files)
def create_scale_bars():
    target_distance = Metashape.app.getFloat("Enter the target distance for the scale bars (in meters):", 0.089)  # Default value is 8.9 cm
    for chunk in Metashape.app.document.chunks:
        # Get the selected cameras
        selected_cameras = [camera for camera in chunk.cameras if camera.selected]
    
        # Deactivate unselected cameras
        # Detect markers only in the selected cameras
        chunk.detectMarkers()
    
        # Get the list of detected markers
        markers = chunk.markers

        # Sort markers based on numeric part of the label
        #
        # Filter markers to only include those starting with the word "target"
        target_markers = [marker for marker in markers if marker.label.lower().startswith('target')]
        target_markers.sort(key=lambda x: int(''.join(filter(str.isdigit, x.label))))
        # Pair consecutive target markers
        paired_markers = [(target_markers[i], target_markers[i + 1]) for i in range(0, len(target_markers) - 1, 2)]
        
        # Check if at least one pair is found
        if not paired_markers:
            print("Not enough consecutive target markers found.")
            return
        
        # Create a scale bar for each pair of target markers
        for marker1, marker2 in paired_markers:
            scale_bar = chunk.addScalebar(marker1, marker2)
            scale_bar.reference.distance = target_distance
        
        print(f"Scale bars created successfully. Target distance: {target_distance} meters.")


def Align3DModels():
    import open3d as o3d
    import numpy as np
    import tempfile
    import os
    import copy

    # Function to get user input for chunk indices
    def get_chunk_indices():
        a = Metashape.app.getInt("Enter the index of the chunk you want to align:", 1)
        b = Metashape.app.getInt("Enter the index of the target chunk (reference chunk):", 0)
        return a, b

    # Create a temporary folder
    temp_folder = tempfile.mkdtemp()
    doc = Metashape.app.document

    # Get user input for chunk indices
    a, b = get_chunk_indices()

    # Load the meshes
    source_mesh = doc.chunks[a].model
    target_mesh = doc.chunks[b].model
    c1 = doc.chunks[a]
    c2 = doc.chunks[b]

    # Export the meshes with normals using Metashape
    c1.exportModel(path=os.path.join(temp_folder, "source_with_normals.ply"), binary=True,
                   save_texture=False, save_uv=False, save_normals=True, save_colors=False,
                   save_cameras=False, save_markers=False, save_udim=False, save_alpha=False,
                   save_comment=False, format=Metashape.ModelFormatPLY)

    c2.exportModel(path=os.path.join(temp_folder, "target_with_normals.ply"), binary=True,
                   save_texture=False, save_uv=False, save_normals=True, save_colors=False,
                   save_cameras=False, save_markers=False, save_udim=False, save_alpha=False,
                   save_comment=False, format=Metashape.ModelFormatPLY)

    # Load the exported meshes with Open3D
    source = o3d.io.read_point_cloud(os.path.join(temp_folder, "source_with_normals.ply"))
    target = o3d.io.read_point_cloud(os.path.join(temp_folder, "target_with_normals.ply"))
    source.paint_uniform_color([1, 0.706, 0])  # Set color for the source mesh
    target.paint_uniform_color([0, 0.651, 0.929])  # Set color for the target mesh

    # Visualize the loaded point clouds
    o3d.visualization.draw_geometries([source, target])

    # Delete the temporary folder and its contents
    for file_name in os.listdir(temp_folder):
        file_path = os.path.join(temp_folder, file_name)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
        except Exception as e:
            print(e)

    os.rmdir(temp_folder)

    trans_init = np.eye(4)

    def draw_registration_result(source, target, transformation):
        source_temp = copy.deepcopy(source)
        target_temp = copy.deepcopy(target)
        source_temp.paint_uniform_color([1, 0.706, 0])
        target_temp.paint_uniform_color([0, 0.651, 0.929])
        source_temp.transform(transformation)
        o3d.visualization.draw_geometries([source_temp, target_temp])

    def prepare_dataset(voxel_size, source, target):
        print(":: Load two point clouds and disturb initial pose.")
        source_down, source_fpfh = preprocess_point_cloud(source, voxel_size)
        target_down, target_fpfh = preprocess_point_cloud(target, voxel_size)
        return source, target, source_down, target_down, source_fpfh, target_fpfh

    def preprocess_point_cloud(pcd, voxel_size):
        print(":: Downsample with a voxel size %.3f." % voxel_size)
        pcd_down = pcd.voxel_down_sample(voxel_size)

        radius_normal = voxel_size * 2
        print(":: Estimate normal with search radius %.3f." % radius_normal)
        pcd_down.estimate_normals(
            o3d.geometry.KDTreeSearchParamHybrid(radius=radius_normal, max_nn=30))

        radius_feature = voxel_size * 5
        print(":: Compute FPFH feature with search radius %.3f." % radius_feature)
        pcd_fpfh = o3d.pipelines.registration.compute_fpfh_feature(
            pcd_down,
            o3d.geometry.KDTreeSearchParamHybrid(radius=radius_feature, max_nn=100))
        return pcd_down, pcd_fpfh

    voxel_size = 0.001  # means 5cm for this dataset
    # source, target, source_down, target_down, source_fpfh, target_fpfh = prepare_dataset(
        # voxel_size, source, target)

    def refine_registration(source, target, source_fpfh, target_fpfh, voxel_size):
        distance_threshold = voxel_size * 0.4
        print(":: Point-to-plane ICP registration is applied on original point")
        print("   clouds to refine the alignment. This time we use a strict")
        print("   distance threshold %.3f." % distance_threshold)
        result = o3d.pipelines.registration.registration_icp(
            source, target, distance_threshold, trans_init)

    # result_icp = refine_registration(source, target, source_fpfh, target_fpfh, voxel_size)
    # o3d.pipelines.registration.registration_icp(source, target, voxel_size * 0.4, trans_init)
    result_icp = o3d.pipelines.registration.registration_generalized_icp(source, target, voxel_size * 0.2, trans_init,o3d.pipelines.registration.
                    TransformationEstimationForGeneralizedICP(),
                    o3d.pipelines.registration.ICPConvergenceCriteria(
                        relative_fitness=1e-6,
                        relative_rmse=1e-6,
                        max_iteration=500))
    draw_registration_result(source, target, result_icp.transformation)
    print("Transformation is:")
    t = Metashape.Matrix(result_icp.transformation)
    print(t)
    c2.transform.matrix = c2.transform.matrix * t


import Metashape

def match_bounding_boxes():
    Metashape.app.messageBox("Please make sure that the reference chunk is the active chunk.!!")
    doc = Metashape.app.document

    # Get the active chunk and its bounding box information
    active_chunk = doc.chunk
    T0 = active_chunk.transform.matrix
    region = active_chunk.region
    R0 = region.rot
    C0 = region.center
    s0 = region.size

    # Iterate through all chunks in the document
    for current_chunk in doc.chunks:
        if current_chunk == active_chunk:
            continue

        # Create a new region object for each chunk
        current_region = Metashape.Region()

        # Compute the transformation matrix for the current chunk
        T = current_chunk.transform.matrix.inv() * T0

        # Extract rotation matrix from the transformation matrix
        R = Metashape.Matrix([[T[0, 0], T[0, 1], T[0, 2]],
                              [T[1, 0], T[1, 1], T[1, 2]],
                              [T[2, 0], T[2, 1], T[2, 2]]])

        # Normalize the rotation matrix to eliminate scaling
        scale = R.row(0).norm()
        R = R * (1 / scale)

        # Update the current region with the transformed values
        current_region.rot = R * R0
        c = T.mulp(C0)
        current_region.center = c
        current_region.size = s0 * scale / 1.0

        # Set the region for the current chunk
        current_chunk.region = current_region

    print("Script finished. Bounding boxes matched.\n")

# Add the custom menu and actions
def create_custom_menu():
    # Add a custom submenu under the Tools menu for "BenthicFriend"
    Metashape.app.addMenuItem("BenthicFriend/CreateChunkAndAddPhotos", create_chunk_and_add_photos)
    Metashape.app.addMenuItem("BenthicFriend/ScaleWithMetashapeTargets",create_scale_bars)    
    Metashape.app.addMenuItem("BenthicFriend/ProcessAllChunks", lambda: process_all_chunks())
    Metashape.app.addMenuItem("BenthicFriend/Align3DModel",Align3DModels)
    Metashape.app.addMenuItem("BenthicFriend/Match Bounding Boxes", match_bounding_boxes)	
    
create_custom_menu()