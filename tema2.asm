;Ghergu Mihai Adrian 321CB
extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

xor_strings:
	; TODO TASK 1
        push ebp
        mov ebp,esp 
        mov ebx, dword [ebp+12]  ;cheie  
        mov ecx, dword [ebp+8]   ;string              
        xor edx,edx 
        xor eax,eax       
xor_wh: 
        mov al, byte [ebx]    ;iau element din cheie
        cmp al,0x00
        je end_x
        mov ah, byte[ecx+edx]     ;elementul de pe poz edx din string
        xor al,ah
        mov byte[ecx+edx],al      ;bag rezultatul xor ului in ecx pe poz edx
        inc edx
        inc ebx                   ;trec mai departe
        jmp xor_wh
      
end_x:
        leave
        ret

rolling_xor:
	; TODO TASK 2
        push ebp
        mov ebp,esp             
        mov ecx, dword [ebp+8];string
        xor edx,edx
        mov bh, byte[ecx+edx];primul element din sting
while_r:   
        inc edx
        mov bl, byte[ecx+edx]   ;elemntul urmator din string
        cmp bl,0x00
        je end_r
        xor bh,bl
        mov byte[ecx+edx],bh    ;bag rezultatul xor ului in ecx pe poz edx
        mov bh,bl           
        jmp while_r
         
end_r:
        leave
        ret
;==============================================
xor_hex_strings:
	; TODO TASK 3
        push ebp
        mov ebp,esp
        mov ecx,[ebp+8];string
        mov edi,[ebp+12];cheie
        xor edx,edx
        xor ebx,ebx
        xor esi,esi
       
rep_xh:
        mov ah,byte[ecx+esi]
        cmp ah,0x00           ;pun in ah,al 2 cate 2 caractere consecutive in string
        je end_xh
        mov al,byte[ecx+esi+1]
              
        mov bh,byte[edi]    ;pun in bh,bl cate 2 caractere consecutive din cheie
        mov bl,byte[edi+1]
        jmp cont
 revin:  
        shl ah,4   
        add ah,al
        shl bh,4
        add bh,bl
        xor ah,bh
        mov byte[ecx+edx],ah
        add esi,2
        add edi,2
        inc edx     
        jmp rep_xh     
 
cont:
        cmp ah,'a'
        jl cifra1          ;aici verific daca fiecare registru initializat
        cmp ah,'f'         ;este litera sau cifra, si apoi in convertesc 
        jg cifra1          ;din string in numar
        sub ah,'a'
        add ah,10
        jmp cont1
cont1: 
        cmp al,'a'
        jl cifra2
        cmp al,'f'
        jg cifra2
        sub al,'a'
        add al,10
        jmp cont2
cont2: 
        cmp bh,'a'
        jl cifra3
        cmp bh,'f'
        jg cifra3
        sub bh,'a'
        add bh,10
        jmp cont3
cont3: 
        cmp bl,'a'
        jl cifra4
        cmp bl,'f'
        jg cifra4
        sub bl,'a'
        add bl,10
        jmp revin 
  
 cifra1: 
        sub  ah,'0'
        jmp cont1 
 cifra2: 
        sub  al,'0'
        jmp cont2 
 cifra3: 
        sub  bh,'0'
        jmp cont3 
 cifra4: 
        sub  bl,'0'
        jmp revin                      
 end_xh:
        mov byte[ecx+edx],0x00  ;pentru a pune null la sfarsit de tot
        leave
	ret
;=================================================
base32decode:
	; TODO TASK 4
        push ebp
        mov ebp, esp
        mov esi, [ebp+8] ; stringul
        mov ecx,edi
        xor edx,edx
base32_wh:
        mov ah, [esi]
        cmp ah, 0x00
        je exit1
        cmp ah, '=' ;sar peste '='
        je skip2
        cmp ah, 'A'  ;daca nu este in intervalul A-Z
        jl cifra     ;fac transformarile corespunzatoare
        cmp ah, 'Z'
        jg cifra
        sub ah, 'A'  
        jmp continua
cifra:
        sub ah, 24
continua:
        inc edx  
        ; in ah am valoare 0-31
        jmp convert     ;deja cifra -> in binar pe 5 biti
   
skip2:
        inc esi
        jmp base32_wh
exit1: 
        mov eax, 5 ; pun 5, adica biti din fiecare cifra
        mul edx    ;nr total de biti
        mov bh, 8
        div bh      ;in al, nr caractere din mesajul final
        ; ECX - se afla la inceputul sirului de 0,1
        ; esi -> ecx
        ; ecx -> edi
        mov esi, ecx
        mov ecx, edi
        xor edx, edx   
rep2: ;parcurg aceasta bucla de al ori
        cmp al, 0
        je exit2   
        jmp toDec ; apelez functia de convert to decimal pt esi.
retConv:   ; din conversia in decimal
        mov word [edi+edx], bx
        add esi,8
        inc edx
        dec al
        jmp rep2
exit2:
        leave
        ret
        
toDec:      ;convertesc din binar in decimal, verificand bitii de 1
        xor bx,bx      
        cmp byte [esi], "1"
        je adun128
intorc128:
        cmp byte [esi+1], "1"
        je adun64
intorc64:  
        cmp byte [esi+2], "1"
        je adun32
intorc32:
        cmp byte [esi+3], "1"
        je adun16
intorc16:
        cmp byte [esi+4], "1"
        je adun8
intorc8:
        cmp byte [esi+5], "1"
        je adun4
intorc4:
        cmp byte [esi+6], "1"
        je adun2
intorc2: 
        cmp byte [esi+7], "1"
        je adun1    
        jmp retConv
 ;adun 128,64,32,16,8,4,2,1 pentru a transforma in decimal                  
adun128:;un binar pe 8 biti
        add bx, 128
        jmp intorc128               
adun64:
        add bx, 64
        jmp intorc64  
adun32:
        add bx, 32
        jmp intorc32  
adun16:
        add bx, 16
        jmp intorc16  
adun8:
        add bx, 8
        jmp intorc8  
adun4:
        add bx, 4
        jmp intorc4  
adun2:
        add bx, 2
        jmp intorc2  
adun1:
        add bx, 1
        jmp retConv                                              
                                                                               
convert:;convertesc din decimal in binar pe 5 biti
        cmp ah, 16
        jge scad16
        mov al, '0'
        stosb
return16: 
        cmp ah, 8
        jge scad8
        mov al, '0'
        stosb
return8:
        cmp ah,4
        jge scad4
        mov al, '0'
        stosb
return4:
        cmp ah,2
        jge scad2
        mov al, '0'
        stosb
return2:
        cmp ah,1
        jge scad1
        mov al, '0'
        stosb
        jmp skip2
;pentru atunci cand trb sa scad din numarul meu 1,2,4,8
scad1:;pentru a mi crea binarul pe 5 biti
        mov al, '1'
        sub ah, 1
        stosb
        jmp skip2    
scad2:
        mov al, '1'
        sub ah, 2
        stosb
        jmp return2       
scad4:
        mov al, '1'
        sub ah, 4
        stosb
        jmp return4 
scad16:
        mov al, '1'
        sub ah, 16
        stosb
        jmp return16
scad8:
        mov al, '1'
        sub ah, 8
        stosb
        jmp return8
      
;=================================================
bruteforce_singlebyte_xor:
	; TODO TASK 5
        push ebp
        mov ebp,esp
        mov ecx,dword[ebp+8];string
        xor edx,edx;contor
        xor eax,eax
while_brute:
        mov al, byte [ecx+edx]      ;adaug element in al
        cmp al, 0x00
        je end_b
        xor al,bl
        mov byte[ecx+edx],al        ;bag rezultatul xor ului in ecx pe poz edx
        inc edx
        jmp while_brute
end_b: 
        leave
        ret
        
decode_vigenere:
	; TODO TASK 6
        push ebp
        mov ebp,esp
        mov ebx,dword[ebp+12];cheie
        mov ecx,dword[ebp+8];string
        xor eax,eax
        xor edx,edx         ;contor

while_decode:      
        mov al,byte[ecx+edx]
        cmp al,0x00
        je end_de           ;daca este null
        cmp al,'a'
        jl skip
        cmp al,'z'
        jg skip        
        mov ah,byte[ebx]
        cmp ah,0x00 
        je reset_key                
        sub ah,'a'     ;offset ul literei
        sub al,ah
        cmp al,'a'
        jl asciiSUBa   ;pentru atunci cand scade codul ascii sub 'a'(adica sub 97)
        mov byte[ecx+edx],al    ;mut in ecx la pozitia edx al
        inc edx
        inc ebx
        jmp while_decode 
        
asciiSUBa: 
        mov ah,'a'     ;cate pozitii a scazut sub litera a
        sub ah,al
        mov al,'z'     
        sub al,ah      ;verific fata de z unde e pozitionat
        inc al
        mov byte[ecx+edx],al
        inc edx        
        inc ebx
        jmp while_decode 
     
skip:
        inc edx            ;sare peste caracterele non alfabetice
        jmp while_decode
        
reset_key:
        xor ebx,ebx         ;imi resetez cheia cand in string mai am caractere
        mov ebx,dword[ebp+12]
        jmp while_decode
               
end_de:
        leave
        ret

;===============================
find_key:;pentru cautarea cheii
        push ebp
        mov ebp,esp
        mov ecx,dword[ebp+8]
        mov ebx,ecx         ;pentru a nu pierde ce am in ecx
un_w:
        mov al,[ebx]        ;pun in al un caracter din ebx
        cmp al, 0x00        ;verific daca e null
        je end_k
        inc ebx             ;trec la urmatorul element
        jmp un_w
end_k:
        inc ebx               ;sar peste null
        leave
        ret
;================================
create_key:
        push ebp
        mov ebp,esp
        mov ecx, dword[ebp+8]
        mov ebx,ecx
        xor eax,eax
        xor edx,edx
    rep_create:
        mov al,byte[ebx]    ;pun in al un caracter din ebx
        cmp al, 0x00        ;verific daca e la sfarsit
        je end_br
        xor al,'f'          ;pentru fiecare element fac xor cu f
        inc edx
        mov ah,byte[ebx+edx];iau urmatorul element din string
        xor ah,al
        ;verific daca pot forma force pornind de la acea pozitie din string
        cmp ah,'o'                          ;prin decodificari
        jne reset           ;opresc crearea cheii si reiau
        inc edx
        mov ah,byte[ebx+edx]
        xor ah,al
        
        cmp ah,'r'
        jne reset
        inc edx
        mov ah,byte[ebx+edx]
        xor ah,al
        
        cmp ah,'c'
        jne reset
        inc edx
        mov ah,byte[ebx+edx]
        xor ah,al
        
        cmp ah,'e'
        jne reset
        inc edx
        mov ah,byte[ebx+edx]
        xor ah,al
        
        xor ebx,ebx
        mov bl,al
        jmp end_br
reset:
        xor edx,edx   ;resetez parcurgerea de la pozitia respectiva
        inc ebx
        jmp rep_create
end_br:
        leave
        ret     
;++++++++++++++++++++++++++++++++  
main:
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 7]
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
	; TASK 1: Simple XOR between two byte streams
        push ecx
        call find_key       ;find the address for the string and the key
        add esp,4
        
        push ebx
        push ecx       
        call xor_strings    ;call the xor_strings function
        add esp, 8

	push ecx
	call puts                   ;print resulting string
	add esp, 4

	jmp task_done

task2:
	; TASK 2: Rolling XOR
        push ecx
        call rolling_xor        ;call the rolling_xor function
        add esp, 4
        
	push ecx
	call puts
	add esp, 4

	jmp task_done

task3:
	; TASK 3: XORing strings represented as hex strings

	; TODO TASK 1: find the addresses of both strings
        push ecx
        call find_key
        add esp,4
	; TODO TASK 1: call the xor_hex_strings function

        push ebx
        push ecx
        call xor_hex_strings
        add esp,8

	push ecx                     ;print resulting string
	call puts
	add esp, 4

	jmp task_done

task4:
	; TASK 4: decoding a base32-encoded string
        
        push ecx
        call base32decode
        add esp,4
	; TODO TASK 4: call the base32decode function
	
	push ecx
	call puts                    ;print resulting string
	pop ecx
	
	jmp task_done

task5:
	; TASK 5: Find the single-byte key used in a XOR encoding

        push ecx
        call create_key
        add esp,4

        push ecx       
        call bruteforce_singlebyte_xor    ;call the bruteforce_singlebyte_xor function
        add esp, 4

	push ecx                    ;print resulting string
	call puts
	pop ecx
        
        xor eax,eax
        mov eax,ebx
        
	push eax                    ;eax = key value
	push fmtstr
	call printf                 ;print key value
	add esp, 8

	jmp task_done

task6:
	; TASK 6: decode Vignere cipher
	push ecx
	call strlen
	pop ecx

	add eax, ecx
	inc eax

	push eax
	push ecx                   ;ecx = address of input string 
	call decode_vigenere
	pop ecx
	add esp, 4

	push ecx
	call puts
	add esp, 4

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret
