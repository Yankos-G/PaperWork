
PROGRAM _INIT

	 
END_PROGRAM

PROGRAM _CYCLIC
	
	gMpRecipeXML_0.MpLink := 		ADR(gRecipeXml);
	gMpRecipeXML_0.Enable := 		TRUE;
	gMpRecipeXML_0.DeviceName :=	ADR('CF'); 
	gMpRecipeXML_0.FileName := 		ADR('FileNameEee'); //zmienic sciezke
	
	gMpRecipeRegPar_0.MpLink := 	ADR(gRecipeXml);
	gMpRecipeRegPar_0.Enable :=		TRUE;
	gMpRecipeRegPar_0.PVName := 	ADR('gSorting');
	
	gMpRecipeUI_0.MpLink :=			ADR(gRecipeXml);
	gMpRecipeUI_0.Enable := 		TRUE;
	gMpRecipeUI_0.UISetup := 		gUISetup;
	gMpRecipeUI_0.UIConnect := 		ADR(gUIConnect);
	
	gSorting.ItemWeightChoosen;
	gSorting.RecognisedModel; //CO TU DAC???
	gSorting.SortLeftMin;
	gSorting.SortChoice;
	
	
	
	//	Parametry sortowania powinno dac sie zapisac oraz wczytac przy uzyciu systemu receptur 
	//	MpRecipe. Na stronie parametr�w powinna wiec istniec mozliwosc przegladania listy dostepnych receptur, 
	//	wczytania receptury z listy, zapisania nowej receptury oraz modyfikacji parametr�w dowolnej z zapisanych 
	//	receptur. Powinno byc takze mozliwe wyswietlenie parametr�w danej receptury bez wczytywania jej oraz 
	//	calkowite usuniecie receptury widocznej na liscie. Zar�wno na stronie parametr�w jak i na stronie pracy automatycznej (oraz przy pracy p�lautomatycznej) powinna byc wyswietlona obecnie wczytana receptura, 
	//	chyba ze uzywane sa aktualnie niezapisane DO receptury, recznie ustawione, parametry sortowania.

	gMpRecipeUI_0();
	gMpRecipeXML_0();
	gMpRecipeRegPar_0();
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM
