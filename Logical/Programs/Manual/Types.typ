
TYPE
	AxisParam : 	STRUCT 
		ManualDistance : LREAL := 500; (*Setting distance of the belt move [mm]*)
		ManualVelocity : REAL := 50; (*Value of velocity [mm/s]*)
	END_STRUCT;
	ManualStepsEnum : 
		(
		MANUAL_WAIT := 10,
		MANUAL_BELT_SET_ADDITIVE := 20,
		MANUAL_BELT_MOVE_ADDITIVE := 30,
		MANUAL_BELT_SET_VELOCITY := 40,
		MANUAL_BELT_MOVE_VELOCITY := 50,
		MANUAL_BELT_MOVE_ADDITIVE1 := 60
		);
	ManualStepsActEnum : 
		(
		MANUAL_ACTUATOR_WAIT := 200,
		MANUAL_ACTUATOR_DOSING := 210,
		MANUAL_ACTUATOR_NONE := 220,
		MANUAL_ACTUATOR_BOTH := 230,
		MANUAL_ACTUATOR_SORTING := 240
		);
	CameraEnum : 
		(
		CAMERA_INIT := 310,
		CAMERA_PHOTO_SHOOT_WAIT := 320,
		CAMERA_PHOTO_DISPLAY_INIT := 330,
		CAMERA_PHOTO_DISPLAY := 340
		);
END_TYPE
