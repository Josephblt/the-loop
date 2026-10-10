class_name Wall


enum WallType {
	NONE,
	BORDER_WALL,
	GATE_WALL,
	MAZE_WALL,
	MEMORY_GATE,
	MEMORY_WALL
}

enum WallDirection {
	NORTH,
	EAST,
	SOUTH,
	WEST
}


var type: WallType = WallType.NONE
var direction: WallDirection = WallDirection.NORTH


static func opposite(wall_direction: WallDirection) -> WallDirection:
	match wall_direction:
		WallDirection.NORTH:
			return WallDirection.SOUTH
		WallDirection.SOUTH:
			return WallDirection.NORTH
		WallDirection.EAST:
			return WallDirection.WEST
		WallDirection.WEST:
			return WallDirection.EAST
		_:
			return WallDirection.NORTH
