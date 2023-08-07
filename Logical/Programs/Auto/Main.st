PROGRAM _INIT
	// NEED ONLY FOR WATCH
	gAxis_1;
	gMotorBeltParType;
	gMotorBeltAxisBasic;
END_PROGRAM
//po namy�le mo�na by�o u�y� struktur do zmiennych :P 
PROGRAM _CYCLIC

	SelectedAuto := (gMode = 0);
	NotSelectedAuto := NOT SelectedAuto;
	
	// CODE WORKS ONLY WHEN AUTO IS ACTIVE
	IF  SelectedAuto THEN
		// MOTOR MANAGEMENT
		gMotorBeltAxisBasic.Enable 		:= TRUE;
		gMotorBeltAxisBasic.MpLink 		:= ADR(gAxis_1);
		gMotorBeltAxisBasic.Parameters 	:= ADR(gMotorBeltParType);
		MotorMoveDone 					:= gMotorBeltAxisBasic.MoveDone;
		gMotorBeltAxisBasic.Power 		:= MotorPower;
		gMotorBeltAxisBasic.Home 		:= MotorHome;
		
		gMotorBeltAxisBasic();
		
		// IN STATE STOP VALUES DOESN'T FLUCTUATE
		IF gMotorBeltAxisBasic.Velocity > 15 THEN
			MotorVel := gMotorBeltAxisBasic.Velocity;
		ELSE
			MotorVel := 0;
		END_IF;
		IF gMotorBeltAxisBasic.Position > 5 THEN
			MotorPos := gMotorBeltAxisBasic.Position;
		ELSE
			MotorPos := 0;
		END_IF;
		
		// ASSIGNING MOTION PARAMETERS
		gMotorBeltParType.Acceleration 	:= MotorReqAcc; 
		gMotorBeltParType.Deceleration 	:= MotorReqDec; 
		gMotorBeltParType.Velocity 		:= MotorReqVel;
		gMotorBeltParType.Position 		:= MotorReqPosition;
	
		// ASSIGNING GLOBAL VARIABLES TO LOCAL VARIABLES
		gActuatorByte					 := ActuatorByte;
		gMotorBeltAxisBasic.Power 		 := MotorPower;
		gMotorBeltAxisBasic.MoveAbsolute := MotorMoveAbsolute;
		gStopState 						 := (State = 0);
		
		// ASSIGNING LOCAL VARIABLES TO GLOBAL VARIABLES
		MotorInPosition 				 := gMotorBeltAxisBasic.InPosition;
		ItemWeight 						 := gInWeightMeasure;							 

		// ITEM DETECTION CONDITION 
		ItemDetected := (ItemWeight > 1);
		gWeightDetected := ItemDetected;
		
		// TIMERS
		// actuator
		TimerTonActuator(IN := TimerTonActuatorIn, PT := TIME_TON_ACTUATOR);
		TimerActuatorOut := TimerTonActuator.Q;
		// camera
		TimerTonCamera(IN := gProgCamera.ImageAcq , PT := TIME_TON_CAMERA);
		TimerCameraPicDone := TimerTonCamera.Q;
		// delay after detection
		TimerTonDetect.IN := ItemDetected;
		TimerTonDetect.PT := TIME_TON_DETECT;
		TimerAfterDetect := TimerTonDetect.Q;
		TimerTonDetect();
	
		
	END_IF; 
		
	
	// ALARM OR STOP OR AUTO NOT ACTIVE
	IF	gAlarmHardware THEN	
		IF NOT (State = ERROR) THEN
			State := ERROR;
		END_IF;
	ELSIF Stop OR gMode <> 0 OR gAlarmExist THEN 
		Stop := FALSE;
		State := STOP;
	END_IF; 
	
	// PROGRAM AUTO
	CASE State OF
		STOP:
			IF SelectedAuto THEN
				MotorPower 		  := FALSE;
				MotorMoveAbsolute := FALSE;
				MotorHome 		  := FALSE;
			END_IF;		
			MotorPos := 0;
			MotorVel := 0;
			TimerTonActuatorIn 	  := FALSE;
			ActuatorSorting 	  := FALSE;
			ActuatorPushing  	  := FALSE;
			IF Start THEN
				State := INIT;
			END_IF;
			
		INIT:
			gAddToRight 		:= FALSE;
			gAddToLeft 			:= FALSE;
			TimerTonActuatorIn 	:= FALSE;
			ActuatorSorting 	:= FALSE;
			ActuatorPushing 	:= FALSE;
			MotorMoveAbsolute 	:= FALSE;
			MotorPower 			:= TRUE;
			MotorHome 			:= TRUE;
			gPicNotRecognised	:= FALSE;
			State 				:= START;
			
		START: 
			IF ItemDetected THEN
				ItemWeightMeasured 	:= RESET_ITEM_MEM_WEIGHT;
				State := DETECTION;
			END_IF;
			
		DETECTION:
			MotorHome 	:= FALSE;
			IF TimerAfterDetect THEN
				ItemWeightMeasured := ItemWeight;
				State := CATEGORIZATION;
			END_IF;
				
		CATEGORIZATION: 
			IF gSorting.SortChoice = WEIGHT THEN
				State := DROP;
			ELSE
				State := TAKE_PICT_CAMERA;
			END_IF;
			
		TAKE_PICT_CAMERA:
			gProgCamera.ImageAcq 	:= TRUE;
			IF TimerCameraPicDone THEN
				gProgCamera.DisplayPhoto := TRUE;
				IF gSorting.RecognisedModel = 0 THEN 						//0
					gProgCamera.ImageAcq  := FALSE;
					State 				  := UNRECOGNISED_PIC;
				ELSE 
					State 				  := DROP;
				END_IF;
			END_IF;
				
		DROP:
			ActuatorPushing := TRUE;
			IF TimerActuatorOut THEN
				ActuatorPushing := FALSE;
				IF gSorting.SortChoice = OPTIC_LOGO THEN
					gSortChoiceView := TRUE;
					State := SORT_OPTIC_LOGO;
				ELSIF gSorting.SortChoice = OPTIC_COLOR THEN
					gSortChoiceView := TRUE;
					State := SORT_OPTIC_COLOR;
				ELSIF gSorting.SortChoice = WEIGHT THEN
					gSortChoiceView := FALSE;
					State := SORT_WEIGHT;
				END_IF;
			END_IF;
			
			// ABOVE 1 TO ItemWeightChoosen ITEM FALL INTO THE LEFT, EQUAL AND ABOVE ItemWeightChoosen INTO THE RIGHT	
		SORT_WEIGHT: 
			IF ItemWeightMeasured > 1 AND ItemWeightMeasured < gSorting.ItemWeightChoosen THEN
				IF gSorting.SortLeftMin THEN
					State := GO_STORAGE_LEFT;
				ELSE
					State := GO_STORAGE_RIGHT;
				END_IF;
			ELSIF ItemWeightMeasured >= gSorting.ItemWeightChoosen THEN 
				IF gSorting.SortLeftMin THEN
					State := GO_STORAGE_RIGHT;
				ELSE
					State := GO_STORAGE_LEFT;
				END_IF;
			END_IF;
			
		SORT_OPTIC_LOGO:
			IF gSorting.RecognisedModel = 1 THEN	
				gProgCamera.ImageAcq 			  := FALSE;					//1
				IF gSorting.SortLeftBR THEN
					State := GO_STORAGE_LEFT;
				ELSE
					State := GO_STORAGE_RIGHT;
				END_IF;
			ELSIF gSorting.RecognisedModel = 2 THEN						
				gProgCamera.ImageAcq 			  := FALSE;						//2
				IF gSorting.SortLeftBR THEN
					State := GO_STORAGE_RIGHT;
				ELSE
					State := GO_STORAGE_LEFT;
				END_IF;
			END_IF;
			
		SORT_OPTIC_COLOR:
			IF gSorting.RecognisedModel = 1 THEN	
				gProgCamera.ImageAcq 			  := FALSE;						//1
				IF gSorting.SortLeftGrey THEN
					State := GO_STORAGE_LEFT;
				ELSE
					State := GO_STORAGE_RIGHT;
				END_IF;
			ELSIF gSorting.RecognisedModel = 2 THEN						
				gProgCamera.ImageAcq 			  := FALSE;					//2
				IF gSorting.SortLeftGrey THEN
					State := GO_STORAGE_RIGHT;
				ELSE
					State := GO_STORAGE_LEFT;
				END_IF;
			END_IF;
			
		GO_STORAGE_LEFT:
			MotorReqPosition := MOTOR_DIST_LEFT;
			MotorMoveAbsolute := TRUE;
			IF MotorInPosition AND MotorMoveDone THEN
				State := SORT_STORAGE_LEFT;
			END_IF;

		GO_STORAGE_RIGHT:
			MotorReqPosition  := MOTOR_DIST_RIGHT;
			MotorMoveAbsolute := TRUE;
			IF MotorInPosition AND MotorMoveDone THEN
				State := SORT_STORAGE_RIGHT;				
			END_IF;
			
		SORT_STORAGE_LEFT:
			MotorMoveAbsolute := FALSE;
			ActuatorSorting   := TRUE;
			gAddToLeft 		  := TRUE;
			IF TimerActuatorOut THEN
				State := INIT;
			END_IF;

		SORT_STORAGE_RIGHT:
			gAddToRight := TRUE;
			MotorMoveAbsolute := FALSE;
			State := INIT;
		
		UNRECOGNISED_PIC:
			gPicNotRecognised := TRUE; 
			State := STOP;
			
		ERROR: // SPONTANICZNA DECYZJA CTRL V Z STOP DLA LEPSZEJ FUNKCJONALNO�CI - BRAKLO CZASU NA DOKLADNIEJSZE POPRAWKI
			IF gMode = 0 THEN
				MotorPower 		  := FALSE;
				MotorMoveAbsolute := FALSE;
				MotorHome 		  := FALSE;
			END_IF;		
			MotorPos := 0;
			MotorVel := 0;
			TimerTonActuatorIn 	  := FALSE;
			ActuatorSorting 	  := FALSE;
			ActuatorPushing  	  := FALSE;
			gErrorState := TRUE;
			IF gAlarmHardAck THEN
				IF NOT gAlarmHardware THEN
					gAlarmHardAck := FALSE;
					gErrorState := FALSE;
					State := STOP;
				END_IF;
			END_IF;
		
	END_CASE;

	
	// TIMER INPUT TRIGGER TO DELAY ACTUATORS
	IF ActuatorPushing OR ActuatorSorting THEN
		TimerTonActuatorIn := TRUE;
	ELSE
		TimerTonActuatorIn := FALSE;
	END_IF;
	
	// OPERATION OF BYTE ACTUATORS WITH TIMER
	IF ActuatorPushing THEN
		ActuatorByte := ACTUATOR_BYTE_PUSH;	
		IF TimerActuatorOut THEN
			ActuatorPushing := FALSE;
		END_IF;
	ELSIF ActuatorSorting THEN
		ActuatorByte := ACTUATOR_BYTE_SORT;
		IF TimerActuatorOut THEN
			ActuatorSorting := FALSE;
		END_IF;
	ELSE
		ActuatorByte := ACTUATOR_BYTE_NOT_ACTIV; 
	END_IF;
	
	// COUNTERS
	gCTU_QuantityLeft(CU := gAddToLeft, RESET := gCTU_Reset_Left, PV := gMaxLeftStorage);
	gCTU_QuantityRight(CU := gAddToRight, RESET := gCTU_Reset_Right, PV := gMaxRightStorage);
	gQuantityLeftStorage  := gCTU_QuantityLeft.CV;
	gQuantityRightStorage := gCTU_QuantityRight.CV;
	
	gCTU_QuantityLeft();
	gCTU_QuantityRight();
	
	// HMI GUYS WANTED SOME VARIABLES
	IF gSorting.SortChoice = OPTIC_LOGO OR gSorting.SortChoice = OPTIC_COLOR THEN
		gSortChoiceView := TRUE;
		ShowLightLeft := FALSE;
		ShowLightRight := FALSE;
		IF gSorting.SortLeftBR THEN
			ShowBRLeft := TRUE;
			ShowBRRight := FALSE;
		ELSE
			ShowBRRight := TRUE;
			ShowBRLeft := FALSE;
		END_IF;
	ELSIF gSorting.SortChoice = WEIGHT THEN
		gSortChoiceView := FALSE;
		ShowBRLeft := FALSE;
		ShowBRRight := FALSE;
		IF gSorting.SortLeftMin THEN
			ShowLightLeft := TRUE;
			ShowLightRight := FALSE;
		ELSE
			ShowLightRight := TRUE;
			ShowLightLeft := FALSE;
		END_IF;
	END_IF;
	
	ActuatorNotSorting := NOT ActuatorSorting;
	ActuatorNotPushing 	:= NOT ActuatorPushing;
	
	IF Start THEN
		Start := FALSE;
	END_IF;
	
	
	//SERVICE PAGE
	//SCALE WEIGHT RESET
	IF HMI_ScaleTare THEN
		ScaleTare := 2#1000;
	ELSE
		ScaleTare := 2#0000;
	END_IF;
	
		END_PROGRAM

PROGRAM _EXIT

	 
		END_PROGRAM
