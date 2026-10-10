class_name Cell


enum CellType {
	GATE,
	MAZE,
	MEMORY
}


var cell_type: CellType = CellType.MAZE

var walls: Dictionary[Wall.WallDirection, Wall] = {
	Wall.WallDirection.NORTH: null,
	Wall.WallDirection.SOUTH: null,
	Wall.WallDirection.EAST: null,
	Wall.WallDirection.WEST: null
}