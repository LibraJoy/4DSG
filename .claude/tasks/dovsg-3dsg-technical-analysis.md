# DovSG 3D Scene Graph (3DSG) Module: Deep Technical Analysis

## Executive Summary

This document provides a comprehensive technical analysis of the DovSG (Dense Open-Vocabulary 3D Scene Graphs) system's 3D Scene Graph module. The analysis covers the complete lifecycle of 3DSG: construction, generation, updating, and visualization, with detailed code references for developers.

**Core Architecture**: The 3DSG system is implemented primarily in two classes:
- `SceneGraphProcesser` (`scene_graph_processer.py:73`) - Core logic for building and updating scene graphs
- `SceneGraph` (`graph.py:30`) - Data structure representing the hierarchical scene graph

**Key Innovation**: DovSG constructs dynamic scene graphs that represent objects as nodes with explicit spatial relationships, enabling language-guided robot manipulation tasks.

## 1. Construction - Initial 3D Scene Graph Creation

### 1.1 Core Architecture

**Primary Class**: `SceneGraphProcesser` (`scene_graph_processer.py:73`)

```python
class SceneGraphProcesser:
    def __init__(
        self,
        part_level_classes: list,
        resolution: float=0.01,
        neighbour_num: int=5,
        stand_floor_threshold: float=0.15,
        alphashape_alpha: float=1,
        alpha_shape_overleaf_rate_threshold: float=0.6,
        part_intersection_rate_threshold: float=0.2,
        inside_threshold: float=0.95
    ):
```

**Key Parameters**:
- `resolution`: Voxel grid resolution for spatial analysis (default: 0.01m)
- `neighbour_num`: Number of spatial neighbors to consider (default: 5)
- `stand_floor_threshold`: Height threshold for floor-standing objects (default: 0.15m)
- `inside_threshold`: Containment threshold for "inside" relationships (default: 0.95)

### 1.2 Construction Process Flow

**Entry Point**: `build_scene_graph()` method (`scene_graph_processer.py:310`)

```python
def build_scene_graph(self, view_dataset: ViewDataset, instance_objects: MapObjectList, instance_scene_graph: Union[SceneGraph, None]=None):
```

**Construction Steps**:

#### Step 1: Root Node Initialization (`lines 317-323`)
```python
if instance_scene_graph is None:
    root_node = ObjectNode(
        parent=None,
        node_class=self.root_node_class,  # "floor"
        node_id=self.root_node_id         # "floor_0"
    )
    instance_scene_graph = SceneGraph(root_node=root_node)
```

#### Step 2: Non-Part Level Object Processing (`lines 329-425`)
- Objects are classified and processed based on spatial relationships
- Objects near the floor (within `stand_floor_threshold`) are connected to root
- Objects supported by other objects create hierarchical relationships

#### Step 3: Part-Level Object Integration (`lines 461-554`)
- Part-level objects (handles, doors, etc.) are identified using `part_level_classes`
- Parts are connected to their parent objects with "belong" relationship
- Spatial analysis determines parent-child relationships

### 1.3 Data Structures

**ObjectNode Class** (`graph.py:5`)
```python
class ObjectNode():
    def __init__(self, parent, node_class, node_id, parent_relation=None, is_part=False):
        self.parent = parent
        self.children = {}
        self.node_class = node_class
        self.node_id = node_id
        self.parent_relation = parent_relation  # "on", "inside", "belong"
        self.is_part = is_part
```

**SceneGraph Class** (`graph.py:30`)
```python
class SceneGraph:
    def __init__(self, root_node: ObjectNode):
        self.root = root_node
        self.object_nodes = {self.root.node_id: self.root}
```

## 2. Generation - Algorithms and Data Processing

### 2.1 Spatial Relationship Analysis

**Core Algorithm**: Voxel-based spatial neighbor detection

**Method**: `get_voxel_neighbours()` (`scene_graph_processer.py:98`)
```python
def get_voxel_neighbours(self, voxels, size):
    offsets = np.arange(-size, size + 1)
    # Creates 3D offset grid for neighbor detection
```

### 2.2 Geometric Processing Algorithms

#### 2.2.1 Alphashape Analysis (`lines 81, 588-656`)
- **Purpose**: Determine containment relationships between objects
- **Parameters**:
  - `alphashape_alpha=1`: Controls shape complexity
  - `alpha_shape_overleaf_rate_threshold=0.6`: Overlap threshold
- **Algorithm**: Creates alpha shapes of parent objects to test child containment

#### 2.2.2 Convex Hull & Delaunay Triangulation (`line 648`)
```python
inside_mask = delaunay_tri.find_simplex(child_points) > 0
if inside_mask.sum() > self.inside_threshold * len(child_points):
    child_node.parent_relation = "inside"
```

**Purpose**: Determines "inside" relationships using geometric containment tests

### 2.3 Spatial Relationship Types

The system generates three primary spatial relationships:

1. **"on"** (`lines 372, 414, 422, 507, 542, 550`): Objects resting on surfaces
2. **"belong"** (`line 486`): Part-level objects belonging to parent objects
3. **"inside"** (`line 653`): Objects contained within other objects

### 2.4 Input Data Processing

**Required Inputs**:
- `ViewDataset`: Camera viewpoints and pose information
- `MapObjectList`: Detected object instances with 3D geometry

**Data Flow**:
1. Object detection results → 3D point clouds
2. Point clouds → Voxel grids for spatial analysis
3. Spatial analysis → Relationship classification
4. Relationship classification → Scene graph construction

## 3. Updating - Dynamic Scene Graph Maintenance

### 3.1 Update Architecture

**Entry Point**: `update_scene_graph()` method (`scene_graph_processer.py:666`)

```python
def update_scene_graph(self, view_dataset: ViewDataset, instance_objects: MapObjectList, history_scene_graph: SceneGraph):
```

**Update Strategy**: Differential updating with three phases:
1. **Deletion**: Remove objects no longer present
2. **Impact Analysis**: Remove affected children of deleted objects
3. **Reconstruction**: Rebuild scene graph with current objects

### 3.2 Update Process Flow

#### Phase 1: Object Change Detection (`lines 667-674`)
```python
class_id_to_instance_object = {ins_obj["class_id"]: ins_obj for ins_obj in instance_objects}
last_step_class_ids = list(history_scene_graph.object_nodes.keys())
last_step_class_ids.remove(self.root_node_id)  # Exclude root
this_step_class_ids = list(class_id_to_instance_object.keys())
del_class_ids = np.setdiff1d(last_step_class_ids, this_step_class_ids)
new_class_ids = np.setdiff1d(this_step_class_ids, last_step_class_ids)
```

#### Phase 2: Affected Node Analysis (`lines 675-684`)
```python
affected_node_class_ids = []
for del_class_id in del_class_ids:
    node = history_scene_graph.object_nodes[del_class_id]
    for object_node in history_scene_graph.object_nodes.values():
        if object_node.parent == node:
            affected_node_class_ids.append(object_node.node_id)
```

**Logic**: When parent objects are deleted, all children must also be removed to maintain graph consistency.

#### Phase 3: Generation-Based Deletion (`lines 686-705`)
```python
delete_node_generation_mapping = {}
for del_class_id in delete_node_class_ids:
    node = history_scene_graph.object_nodes[del_class_id]
    delete_node_generation_mapping[del_class_id] = {
        "generation": self.calculate_generation(node),
        "node": node
    }
```

**Strategy**: Delete nodes in generation order (leaves first) to prevent orphaned nodes.

#### Phase 4: Scene Graph Reconstruction (`lines 706-712`)
```python
instance_scene_graph = self.build_scene_graph(
    view_dataset=view_dataset,
    instance_objects=instance_objects,
    instance_scene_graph=history_scene_graph
)
assert len(instance_scene_graph.object_nodes) == len(class_id_to_instance_object) + 1
```

**Integration**: Reuse existing construction logic with updated object list.

### 3.3 Update Consistency Guarantees

**Invariants Maintained**:
1. **Single Root**: Always maintains floor-based root node
2. **No Orphans**: Deleted parent nodes trigger child deletion
3. **Consistent Counts**: Final node count equals objects + root
4. **Valid Relationships**: All spatial relationships remain valid

**Generation Calculation** (`lines 658-664`)
```python
def calculate_max_generation(self, node, current_generation=0):
    max_generation = current_generation
    for child in list(node.children.values()):
        child_generation = self.calculate_max_generation(child, current_generation + 1)
        max_generation = max(max_generation, child_generation)
    return max_generation
```

## 4. Visualization - Rendering and Display Systems

### 4.1 Scene Graph Visualization

**Primary Method**: `SceneGraph.visualize()` (`graph.py:53`)

```python
def visualize(self, save_dir):
    dag = graphviz.Digraph(
        directory=f"{str(save_dir)}", filename="scene_graph"
    )
```

**Technology**: Uses `graphviz` library for hierarchical graph rendering

#### 4.1.1 Node Visualization (`lines 60-87`)

**Node Color Coding System**:
```python
if child.is_part:
    color = "darkorange"          # Part-level objects (handles, doors)
elif child.parent_relation == "inside":
    color = "green"               # Objects inside containers
elif len(child.children) == 0:
    color = "lightsalmon"        # Leaf nodes (no children)
else:
    color = "lightblue2"         # Regular parent objects
```

**Node Properties**:
- **Shape**: "egg" shape for all nodes
- **Style**: "filled" with color coding
- **Label**: Object class ID for identification

#### 4.1.2 Edge Visualization (`lines 89-95`)
```python
dag.edge(
    tail_name=node.node_id,
    head_name=child.node_id,
    label=child.parent_relation  # "on", "inside", "belong"
)
```

**Edge Labels**: Show spatial relationship types between connected nodes

#### 4.1.3 Output Generation (`line 97`)
```python
dag.render()  # Generates scene_graph.pdf in save_dir
```

### 4.2 3D Point Cloud Visualization

**Integration Points**: Scene graph visualization works alongside 3D geometry visualization

#### 4.2.1 Open3D Integration (`scene_graph_processer.py:304-306`)
```python
o3d.visualization.draw_geometries(
    [scene_pc] + extra, point_show_normal=True
)
```

**Visualization Components**:
- Point clouds representing object geometry
- Arrow visualizations for spatial relationships
- Interactive 3D manipulation interface

#### 4.2.2 Additional Visualization Modules

**Point Cloud Display**: `show_pointcloud.py`
- Renders RGB-D point clouds with pose trajectories
- Integration with scene graph object instances
- Color-coded object segmentation

**Instance Visualization**: `visualize_instances.py`
- Object instance-specific visualization
- Bounding box and mask overlays
- Multi-view instance display

### 4.3 Controller Integration

**Scene Graph Visualization Trigger** (`controller.py:1355`)
```python
self.instance_scene_graph.visualize(save_dir=self.memory_dir)
```

**Integration Flow**:
1. Scene graph construction/update
2. Automatic visualization generation
3. PDF output saved to memory directory
4. Accessible for research demonstrations

### 4.4 Visualization Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DovSG Visualization Stack               │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────────────────────┐ │
│  │  Scene Graph    │    │     3D Point Cloud             │ │
│  │  Visualization  │    │     Visualization              │ │
│  │                 │    │                                 │ │
│  │  ┌───────────┐  │    │  ┌─────────────┐                │ │
│  │  │ Graphviz  │  │    │  │  Open3D     │                │ │
│  │  │ Digraph   │  │    │  │ Geometries  │                │ │
│  │  └───────────┘  │    │  └─────────────┘                │ │
│  │                 │    │         │                       │ │
│  │  ┌───────────┐  │    │  ┌─────────────┐                │ │
│  │  │   PDF     │  │    │  │ Interactive │                │ │
│  │  │  Output   │  │    │  │   Window    │                │ │
│  │  └───────────┘  │    │  └─────────────┘                │ │
│  └─────────────────┘    └─────────────────────────────────┘ │
│           │                        │                        │
│           └────────┬───────────────┘                        │
│                    │                                        │
│            ┌─────────────────┐                              │
│            │   Controller    │                              │
│            │   Integration   │                              │
│            └─────────────────┘                              │
└─────────────────────────────────────────────────────────────┘
```

## 5. Technical Specifications

### 5.1 Configuration Parameters

**Spatial Analysis Thresholds**:
- `resolution=0.01`: Voxel grid resolution (1cm)
- `neighbour_num=5`: Spatial neighbor analysis count
- `stand_floor_threshold=0.15`: Floor standing height threshold (15cm)
- `inside_threshold=0.95`: Containment detection threshold (95%)

**Geometric Processing**:
- `alphashape_alpha=1`: Alpha shape complexity parameter
- `alpha_shape_overleaf_rate_threshold=0.6`: Overlap rate for containment (60%)
- `part_intersection_rate_threshold=0.2`: Part attachment threshold (20%)

### 5.2 Data Flow Architecture

```
Input Data → Spatial Analysis → Relationship Classification → Scene Graph Construction → Visualization

ViewDataset ──┐
              ├── SceneGraphProcesser ──> SceneGraph ──> Graphviz PDF
MapObjectList ─┘                                    └──> Open3D 3D View
```

### 5.3 Performance Characteristics

**Memory Usage**:
- Scene graph grows linearly with object count
- Each node stores: parent reference, children dictionary, metadata

**Computational Complexity**:
- Construction: O(n²) for spatial relationship analysis
- Update: O(n) for differential updates + O(m²) for new objects (where m << n)
- Visualization: O(n) for graph traversal

### 5.4 Dependencies

**Core Libraries**:
- `graphviz`: Scene graph visualization
- `open3d`: 3D geometry processing and visualization
- `numpy`: Numerical computations
- `scipy.spatial`: Geometric algorithms (ConvexHull, Delaunay)
- `alphashape`: Geometric containment analysis

**File Dependencies**:
- `dovsg/memory/scene_graph/scene_graph_processer.py`: Core logic
- `dovsg/memory/scene_graph/graph.py`: Data structures
- `dovsg/controller.py`: Integration and orchestration

## 6. Usage Patterns and Integration

### 6.1 Typical Usage Flow

**Initial Construction** (`controller.py:920-932`):
```python
def get_instance_scene_graph(self, is_visualize=True):
    if self.instance_scene_graph_path.exists():
        # Load existing scene graph
        with open(self.instance_scene_graph_path, "rb") as f:
            self.instance_scene_graph = pickle.load(f)
    else:
        # Build new scene graph
        scenegraphprocesser = SceneGraphProcesser(
            part_level_classes=self.part_level_classes,
            resolution=self.resolution
        )
        self.instance_scene_graph = scenegraphprocesser.build_scene_graph(
            view_dataset=self.view_dataset,
            instance_objects=self.instance_objects
        )
```

**Dynamic Updates** (`controller.py:1343-1355`):
```python
def update_scene_graph(self):
    scenegraphprocesser = SceneGraphProcesser(
        part_level_classes=self.part_level_classes,
        resolution=self.resolution
    )
    self.instance_scene_graph = scenegraphprocesser.update_scene_graph(
        view_dataset=self.view_dataset,
        instance_objects=self.instance_objects,
        history_scene_graph=self.instance_scene_graph
    )
    self.instance_scene_graph.visualize(save_dir=self.memory_dir)
```

### 6.2 Robot Task Integration

The 3DSG system directly supports robot manipulation tasks:

**Task Planning Integration** (`task_planning/gpt_task_planning.py`):
- Scene graph provides spatial context for task planning
- Relationship queries enable object localization
- Hierarchical structure supports complex manipulation sequences

**Example Query Capabilities**:
- "Find objects on the table" → Query nodes with parent_relation="on"
- "Objects inside containers" → Query nodes with parent_relation="inside"
- "Handle of the cabinet" → Query part-level nodes with parent_relation="belong"

## 7. Future Development Considerations

### 7.1 Scalability Improvements

**Optimization Opportunities**:
- Incremental spatial analysis for large scenes
- GPU-accelerated geometric computations
- Hierarchical spatial indexing for faster neighbor queries

**Memory Optimization**:
- Lazy loading of detailed geometric data
- Compressed point cloud representations
- Efficient scene graph serialization

### 7.2 Enhanced Visualization

**Potential Enhancements**:
- Interactive web-based scene graph visualization
- Real-time 3D scene graph overlay on point clouds
- Temporal visualization showing scene graph evolution
- Multi-scale visualization for complex scenes

### 7.3 Algorithm Extensions

**Research Directions**:
- Probabilistic spatial relationships
- Temporal consistency across scene updates
- Semantic relationship enrichment beyond spatial
- Integration with natural language descriptions

## 8. Conclusion

The DovSG 3D Scene Graph module represents a sophisticated system for constructing, maintaining, and visualizing hierarchical spatial representations of 3D environments. The system's key strengths include:

**Technical Excellence**:
- Robust geometric algorithms for spatial relationship detection
- Efficient differential updating for dynamic scenes
- Comprehensive visualization supporting both graph and 3D views
- Clean separation of concerns between data structures and algorithms

**Research Value**:
- Enables language-guided robot manipulation through structured scene representation
- Provides foundation for complex task planning and execution
- Supports both static scene analysis and dynamic environment adaptation

**Production Readiness**:
- Well-parameterized system with configurable thresholds
- Comprehensive error handling and consistency checks
- Modular design enabling easy extension and modification
- Integration with standard robotics pipelines

This technical analysis provides developers with actionable insights for extending, debugging, and optimizing the DovSG 3DSG system for research and practical applications.

---

**Document Version**: 1.0
**Last Updated**: January 2025
**Target Audience**: Research developers working with DovSG system
**Code Base Version**: Based on DovSG Docker environment analysis