include Irvine32.inc

.data
endl EQU <0dh,0ah>	; end of line sequence
message LABEL BYTE
	BYTE "                                                                          " ,endl
	BYTE "                                                                          " ,endl
	BYTE "      __   __  _______  __    _  _______  __   __  ______  __    _       " ,endl
	BYTE "     |  | |  ||   _   ||  |  | ||       ||  |_|  ||   _  ||  |  | |      " ,endl
	BYTE "     |  ||  ||  ||  ||   || ||    __||      |  |||  ||  ||| |   |   " ,endl
	BYTE "     |       ||       ||       ||   | __ |       ||      ||    |  |      " ,endl
	BYTE "     |       ||       ||  _    ||   ||  ||       ||   _  ||  _    |      " ,endl
	BYTE "     |   _   ||   _   || | |   ||   || |||  | |  || |   |||   |   | " ,endl
	BYTE "     || |||| ||||  |||||||  ||||| ||||  ||||| ||||| |   ||| |   | | " ,endl
	BYTE "                                                                          " ,endl
	BYTE "                      BY: Zunaira Manha Huzaila                       " ,endl

messageSize DWORD ($-message)
    ; Words to guess
    word1 BYTE "ball", 0
    word2 BYTE "tall", 0
    word3 BYTE "hall", 0
    word4 BYTE "tree", 0
    word5 BYTE "book", 0
    word6 BYTE "flower", 0
    word7 BYTE "garden", 0
    word8 BYTE "library", 0
    word9 BYTE "mountain", 0

    ; Array of pointers to each string
    wordArray DWORD OFFSET word1, OFFSET word2, OFFSET word3, OFFSET word4, OFFSET word5, OFFSET word6, OFFSET word7, OFFSET word8, OFFSET word9
    
    len DWORD 0
    cmpcheck DWORD 0
    secretWord BYTE 100 DUP(0)
    guessedWord BYTE 100 DUP(0)
    charToCmp BYTE ?
    CurrChoc BYTE 1
    nooftrys DWORD 1
    wordIndex DWORD 0

    ; Prompts
    bgprompt1 BYTE "Welcome To Hangman", 0
    bgprompt2 BYTE "==================", 0
    bgprompt3 BYTE "Guess the word in 7 tries, or the man dies!", 0
    Hint BYTE "       Psst.... A little hint, try to start with vowels", 0
    tg BYTE "Try again, Be careful...", 0
    gameover BYTE "He Died.....Game over", 0
    winprompt BYTE "  YAY!!! You Guessed the word!!!", 0
    guswi BYTE "                Guessed word is: ", 0
    vWord BYTE "The word was: ", 0
    spacesToClearTryAgainMsg BYTE "                                   ", 0
    pgmsg BYTE "Press 1 to play again.....", 0

    
    

    ; Hangman stages
    s1line1 BYTE "                    _____               ",0
    s1line2 BYTE "                    _____               ",0Dh,0Ah,"                   |",0Dh,0Ah,"                   |",0Dh,0Ah,0
    s1line3 BYTE "                    _____               ",0Dh,0Ah,"                   |     |",0Dh,0Ah,"                   |     |",0Dh,0Ah,0
    s1line4 BYTE "                    _____               ",0Dh,0Ah,"                   |     |",0Dh,0Ah,"                   |     |",0Dh,0Ah,"                    -----               ",0  
    s1line5 BYTE "                    _____               ",0Dh,0Ah,"                   |     |",0Dh,0Ah,"                   |     |",0Dh,0Ah,"                    -----               ",0Dh,0Ah,"                      |",0Dh,0Ah,"                      |",0Dh,0Ah,"                      |",0   
    s1line6 BYTE "                    _____               ",0Dh,0Ah,"                   |     |",0Dh,0Ah,"                   |     |",0Dh,0Ah,"                    -----               ",0Dh,0Ah,"                     /|\",0Dh,0Ah,"                      |",0Dh,0Ah,"                      |",0  
    s1line7 BYTE "                    _____               ",0Dh,0Ah,"                   |     |",0Dh,0Ah,"                   |     |",0Dh,0Ah,"                    -----               ",0Dh,0Ah,"                     /|\",0Dh,0Ah,"                      |",0Dh,0Ah,"                     /|\",0  


.code
main proc
Start:
    
    call Clrscr
    mov edx,offset message
    call WriteString
    mov nooftrys, 1
    call ResetGuessArray
    call ResetSecretArray
    call SetWord

    ; Print game instructions
    mov edx, OFFSET bgprompt1
    call WriteString
    call Crlf
    mov edx, OFFSET bgprompt2
    call WriteString
    call Crlf
    mov edx, OFFSET bgprompt3
    call WriteString
    call Crlf
    call Crlf

   
   

GameLoop:
    call DrawScreen
    mov al, 0
    mov charToCmp, 0
    mov esi, OFFSET secretWord
    INVOKE str_length,esi
 
   mov ecx,eax

    cmp nooftrys, 7
    je GameEnd

    call ReadChar
    call crlf
    
    cmp al, 'Z'        ; Check if the character is > 'Z'
    jg NotUppercase    ; If greater, it's not uppercase
    cmp al, 'A'        ; Check if the character is < 'A'
    jl NotUppercase    ; If less, it's not uppercase
    add al, 32         ; Convert to uppercase by adding 32
NotUppercase:                ; Convert input to uppercase
    mov charToCmp, al ; user input char moved to chartocmp
    ;jmp CheckLoop

;mov ecx,ecx
CheckLoop:
    mov al, [esi]
    cmp al, 0 
    je WrongGuess
    cmp al, charToCmp
    je CorrectGuess
    ;jne WrongGuess
    inc esi

  loop CheckLoop
jmp WrongGuess
CorrectGuess:
    mov CurrChoc, 1
    mov ebx, esi
    sub ebx, OFFSET secretWord
    mov esi, OFFSET guessedWord
    add esi, ebx
    mov [esi], al
    add cmpcheck, 1
    mov esi, OFFSET secretWord
    add esi, ebx
    mov byte ptr [esi], '-'
    call crlf
    mov edx, OFFSET guessedWord
    call WriteString
    mov ebx, cmpcheck
    call crlf
    cmp ebx, len  
    je WordGuessed
    jmp GameLoop

WrongGuess:
    mov CurrChoc, 0
    inc nooftrys
    mov edx, OFFSET tg
    call WriteString
    call crlf
    jmp GameLoop

WordGuessed:
    call DrawScreen
    mov edx, OFFSET winprompt
    call WriteString
    call crlf
    jmp GameEnd

GameEnd:
    mov edx, OFFSET vWord         ; Print "The word was: "
    call WriteString
    push ebx                      ; Preserve EBX
    mov ebx, wordIndex            ; Load the index of the selected word
    mov eax, ebx                  ; Copy index to EAX for calculation
    shl eax, 2                    ; Multiply index by 4 (size of DWORD)
    mov edx, OFFSET wordArray     ; Base address of wordArray
    add edx, eax                  ; Get address of the pointer in the array
    mov edx, [edx]                ; Dereference to get the address of the actual word
    call WriteString              ; Print the word
    call Crlf                     ; Move to the next line
    mov edx, OFFSET pgmsg         ; Print the "Press 1 to play again" message
    call WriteString
    call ReadDec                  ; Read input from user
    pop ebx                       ; Restore EBX

    
    cmp eax, 1
    je Start
    exit
main endp
DrawScreen PROC
    ; Draw stickman based on the number of wrong tries
 
    cmp nooftrys, 2
    je Stage2
    cmp nooftrys, 3
    je Stage3
    cmp nooftrys, 4
    je Stage4
    cmp nooftrys, 5
    je Stage5
    cmp nooftrys, 6
    je Stage6
    cmp nooftrys, 7
    je Stage7
    ret


Stage2:
    mov edx, OFFSET s1line2
    call WriteString
    ret

Stage3:
    mov edx, OFFSET s1line3
    call WriteString
    ret

Stage4:
    mov edx, OFFSET s1line4
    call WriteString
    ret

Stage5:
    mov edx, OFFSET s1line5
    call WriteString
    ret

Stage6:
    mov edx, OFFSET s1line6
    call WriteString
    ret

Stage7:
    mov edx, OFFSET s1line7
    call WriteString
    ret
DrawScreen ENDP

SetWord PROC
    call Randomize
    mov eax, 9
    call RandomRange
    mov wordIndex, eax
    mov edx, wordArray[eax * 4]
    mov esi, edx
    mov edi, OFFSET secretWord
    mov ecx, 0
CopyWord:
    mov al, [esi]
    cmp al, 0
    je DoneCopy
    mov [edi], al
    mov byte ptr [OFFSET guessedWord + ecx], '_'
    inc esi
    inc edi
    inc ecx
    jmp CopyWord

DoneCopy:
    mov len, ecx
    mov byte ptr [edi], 0
    ret
SetWord ENDP

ResetGuessArray PROC
    mov esi, OFFSET guessedWord
    mov ecx, 50
ZeroGuessArray:
    mov byte ptr [esi], 0
    inc esi
    loop ZeroGuessArray
    ret
ResetGuessArray ENDP

ResetSecretArray PROC
    mov esi, OFFSET secretWord
    mov ecx, 50
ZeroSecretArray:
    mov byte ptr [esi], 0
    inc esi
    loop ZeroSecretArray
    ret
ResetSecretArray ENDP

end main