
; Print a note in Allegro commadn line when this script is loaded.
println "Loading Stackup Controller. Created by EricCC Huang (c) 2025"

; Register this command, so we can start it from Allegro command line.
axlCmdRegister( "setDielectricConst" `setDielectricConst)

procedure(setDielectricConst(brdFile)
    ; Set the Dielectric Constant with Excel File.
    
    ; Get board stackup info.
    axlOpenDesign(?design brdFile)
    allLayers = axlXSectionGet(nil 'all)  ; Get all layers' dbid.
    dielectricLayers = removeOddIndexItems(allLayers) ; It stores dbid.
    
    ; Set stackup dielectric constant.
    dielectricConstVal = readDielectricConst()
    idxForDieConst = 0
    foreach(layer dielectricLayers
        modifyDC = axlXSectionModify(?dielectricConst nth(idxForDieConst dielectricConstVal))
        res = axlXSectionSet(layer modifyDC)
        idxForDieConst = idxForDieConst + 1
    )
    axlSaveDesign(?design brdFile ?noConfirm t)  ; Save file (overwrite).
)


procedure(removeOddIndexItems(allLayersList)
    ; Just get the indice for the layers we are going to modify.
    noSurfaceList = removeFirstAndLast(allLayersList)
    let((result index)
        result = nil  ; Initialize an empty list for the result.
        index = 0     ; Index starts at 0.

        foreach(item noSurfaceList
            ; Check if the index is even
            if(mod(index 2) == 0 then
                result = cons(item result)  ; Add item to result if index is even.
            )
            index = index + 1  ; Increment the index.
        )
        
        ; Reverse the result to preserve the original order.
        reverse(result)
    )
)


procedure(removeFirstAndLast(allLayersList)
    let((trimmedList)
        ; Remove the first element using cdr.
        removeFirst = cdr(allLayersList)
        
        ; Remove the last element by reversing, removing the first, and reversing back.
        removeLast = cdr(reverse(removeFirst))
        reverse(removeLast)  ; Directly return.
    )
)

procedure(readDielectricConst()
    ; Read txt file to get the dielectric constant values as a list.
    let((fileHandle line resultList)
        resultList = nil
        
        ; Open txt file.
        fileHandle = infile("C:/BIOS/Skill/DC.txt")
        
        ; Check if the txt file was opened successfully.
        if(!fileHandle then
           error("Failed to open file: %s\n" "C:/BIOS/Skill/DC.txt")
           )
        
        ; Read each line from the txt file.
        when(fileHandle
            while(gets(line fileHandle)
                ; Replace "\n" with "".
                rexC = rexCompile("\n")
                targetVal = rexReplace(line "" 0)
                resultList = cons(targetVal resultList)  ; Add the value to the resultList.
            )
            close(fileHandle)
        )
        
        reverse(resultList)
    )
)
