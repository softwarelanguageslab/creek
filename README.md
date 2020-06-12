# Creek

## Remarks

	* Slack 29/5/2020 11PM:
	  Een fanout is eigenlijk een operator die een meta-message add-subscriber verstaat 

	* Parallel operator implementeren

	* Namen uitvinden voor de "containers" voor een operator 
	  -> "den interpreter" is niet genoeg.
	  -> Bvb een "vat" bevat verschillende operators..

	  Stream vat 
	  -----------
	  meerdere operators 



	* any?/all? predicate op meta-niveau om and/or semantiek te encoderen.
	* Skip propagaten (ivm and/or semantiek)

	* async tick/tock?

	* De operator programmeur bestaat niet

	* Nadenken over de primitieve communicatie concepten
	  -> tick/tock? 


## Notes

 * Ik denk niet dat operator fusion kan uitgedrukt worden op deze manier.
   Dat is iets dat in een imperatieve manier moet uitgedrukt worden?
 * Stel dat we enkel next events willen afhandelen, hoe gaan we duidelijk maken aan de runtime dat we de rest "negeren"?

## DIrectFlow 

 * Alles zit op 1 thread 
 * Componenten hebben fixed in/outs.
 * Segmenten van een pipe kunnen op 1 thread bollen (VAT wat wolf voorstelde)