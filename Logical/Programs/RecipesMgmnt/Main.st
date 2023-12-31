
PROGRAM _INIT
// ==========================================================================================
// ====================PROGRAM WYMAGA UTWORZENIA 3 FOLDER�W NA KARCIE PLC!!!=================
// =============Nazwy=Folder�w====Audit====Recipes====Alarms=================================
// ==========================================================================================
END_PROGRAM

PROGRAM _CYCLIC
	// AUDIT
	MpAuditTrailUI_0(MpLink := ADR(gAuditTrail), Enable := TRUE, UISetup := AuditUISetup, UIConnect := ADR(AuditUIConnect) );
	MpAuditTrail_0(MpLink := ADR(gAuditTrail), Enable := TRUE, DeviceName := ADR('CF_Au'));
	MpAuditTrail_0.Language := ADR(lang);
	MpAuditTrail_0.Export := FALSE;
	
	IF ClearAudit THEN
		MpAuditClearBuffer(MpLink := gAuditTrail);
	END_IF;
	
	// FILE MANAGEMENT
	MpFileManagerUI_0(MpLink := ADR(gFileManageUI), Enable := TRUE , UISetup := FileUISetup, UIConnect := ADR(FileUIConnect) );
	FileUIConnect.DeviceList.DeviceNames[0] := 'EF'; 
	
	i := 0;
	FOR i := 0 TO 5 DO
		FileName[i] := FileUIConnect.File.List.Items[i].Name;
		FileLastModified[i] := FileUIConnect.File.List.Items[i].LastModified;
		FileSize[i] := FileUIConnect.File.List.Items[i].Size;
	END_FOR;
	
	FileUIConnect.File.List.Items[idx].IsSelected := TRUE;
	CurrentFile := FileUIConnect.File.List.Items[idx].Name;
	
	CASE Filter_sort_type OF
		0:
			FileUIConnect.File.SortOrder := mpFILE_SORT_BY_NAME_ASC;
		1:
			FileUIConnect.File.SortOrder := mpFILE_SORT_BY_NAME_DESC;
		2:
			FileUIConnect.File.SortOrder := mpFILE_SORT_BY_SIZE_ASC;
		3:
			FileUIConnect.File.SortOrder := mpFILE_SORT_BY_SIZE_DES;
		4:
			FileUIConnect.File.SortOrder := mpFILE_SORT_BY_MOD_TIME_ASC;
		5:
			FileUIConnect.File.SortOrder := mpFILE_SORT_BY_MOD_TIME_DESC;
	END_CASE;
	
	gMpRecipeRegPar_0.MpLink := 	ADR(gRecipeXml);
	gMpRecipeRegPar_0.Enable :=		TRUE;
	gMpRecipeRegPar_0.PVName := 	ADR('gSorting');

	gMpRecipeXML_0.MpLink := 		ADR(gRecipeXml);
	gMpRecipeXML_0.Enable := 		TRUE;
	gMpRecipeXML_0.DeviceName :=	ADR('CF');  
	
	gMpRecipeUI_0.MpLink :=			ADR(gRecipeXml);
	gMpRecipeUI_0.Enable := 		TRUE;
	gMpRecipeUI_0.UISetup := 		gUISetup;
	gMpRecipeUI_0.UIConnect := 		ADR(gUIConnect);
	gUIConnect.Recipe.SortOrder := mpRECIPE_UI_SORT_DATE_ASCENDING;
	
	gMpRecipeRegPar_0();
	gMpRecipeXML_0();
	gMpRecipeUI_0();
	
	IF Clear_param THEN
		gSorting := CLEAR_ADV_RECIPE;
		Clear_param := FALSE;
	END_IF;
	
	//-----------management-of-adv-buttons--- (almost -30 bindings) 
	IF gSorting.LeftCriteria.AS OR gSorting.RightCriteria.AS OR gCamera_0L_1C = 1 THEN
		AS_visible := FALSE;
	ELSE
		AS_visible := TRUE;
	END_IF;
	IF gSorting.LeftCriteria.BR OR gSorting.RightCriteria.BR OR gCamera_0L_1C = 1 THEN
		BR_visible := FALSE;
	ELSE
		BR_visible := TRUE;
	END_IF;
	IF gSorting.LeftCriteria.Orange OR gSorting.RightCriteria.Orange OR gCamera_0L_1C = 0 THEN
		Orange_visible := FALSE;
	ELSE
		Orange_visible := TRUE;
	END_IF;
	
	IF gSorting.LeftCriteria.Grey OR gSorting.RightCriteria.Grey OR gCamera_0L_1C = 0 THEN
		Grey_visible := FALSE;
	ELSE
		Grey_visible := TRUE;
	END_IF;
	IF gSorting.LeftCriteria.Light OR gSorting.RightCriteria.Light THEN
		Light_visible := FALSE;
	ELSE
		Light_visible := TRUE;
	END_IF;
	IF gSorting.LeftCriteria.Heavy OR gSorting.RightCriteria.Heavy THEN
		Heavy_visible := FALSE;
	ELSE
		Heavy_visible := TRUE;
	END_IF;
	
	
	
	
END_PROGRAM

PROGRAM _EXIT
	 
END_PROGRAM

