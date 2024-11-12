;Project by Ryyan Choudhary() and Usama Zafar()
;Ping Pong Game in Assembly
[org 0x100]
jmp mainPhase

clrscrntoBlack:
push bp
mov bp,sp
push es 
push ax 
push cx 
push di 

mov ax,0xB800
mov es,ax
xor di,di 
mov ax,0x0720
mov cx,2000

cld 
rep stosw 

pop di 
pop cx 
pop ax 
pop es 
pop bp 
ret

mainPhase:
;code
call clrscrntoBlack

updatePhase:
;code

displayPhase:
;code

endGame:
mov ax,0x4C00
int 0x21



