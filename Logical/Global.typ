
TYPE
	ModelEnum : 
		(
		BR_Szary := 1, (*%ID of B&R logo model*)
		AS_Oranz := 2, (*%ID of AS logo model*)
		Unrecognised := 0 (*%case of nothing recognised*)
		);
	SortingType : 	STRUCT 
		RecipeName : STRING[80];
		Date : STRING[80];
		SortChoice : SortChoiceEnum;
		SortLeftMin : BOOL;
		SortLeftBR : BOOL;
		SortLeftGrey : BOOL;
		ItemWeightLeftMin : USINT;
		ItemWeightLeftMax : USINT;
		ItemWeightRightMin : USINT;
		ItemWeightRightMax : USINT;
		ItemWeightBorderWeight : USINT;
		Threshold : BOOL;
		LeftCriteria : Criteria;
		RightCriteria : Criteria;
	END_STRUCT;
	SortChoiceEnum : 
		(
		WEIGHT := 0,
		OPTIC_LOGO := 1,
		OPTIC_COLOR := 2,
		ADVANCED := 3
		);
	Camera_enum_main : 	STRUCT 
		ModuleOK : BOOL;
		LED : USINT;
		Model_ID : USINT;
		PhotoTaken : USINT;
		SetFocus : UINT;
		SetExpo : UDINT;
		ReadFocus : UINT;
		ReadExpo : UDINT;
		ImageAcq : BOOL;
		DisplayPhoto : BOOL;
		ImageProcessingActive : BOOL;
	END_STRUCT;
	Criteria : 	STRUCT 
		AS : BOOL;
		BR : BOOL;
		Grey : BOOL;
		Orange : BOOL;
		Threshold : BOOL;
		Range : BOOL;
		Heavy : BOOL;
		Light : BOOL;
		WeightMin : USINT;
		WeightMax : USINT;
		WeightBorder : USINT;
	END_STRUCT;
END_TYPE
