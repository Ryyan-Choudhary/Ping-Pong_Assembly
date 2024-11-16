;Project by Ryyan Choudhary() and Usama Zafar()
;Ping Pong Game in Assembly
[org 0x100]
jmp mainPhase

Player1: dw 60
Player2: dw 3900
Oldkbisroffset: dw 0
Oldkbisrsegment: dw 0
Paddle_Size: dw 20
Ball_Location: dw 3760
intromsg: db 'Press enter to start!'

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

printPaddles:
push bp 
mov bp,sp 
push es 
push ax 
push bx 
push cx 
push es 
push si 
push di

mov ax,0xB800
mov es,ax
xor di,di 
xor si,si

mov cx,80
mov si,0
mov di,3840

clearpaddleloop:
mov word [es:si],0x0720
mov word [es:di],0x0720

add si,2
add di,2

dec cx
cmp cx,0
jne clearpaddleloop


mov si,[Player1]
mov di,[Player2]
mov cx,[Paddle_Size]

drawpaddleloop:
mov word [es:si],0x07DB
mov word [es:di],0x07DB

add si,2
add di,2

dec cx
cmp cx,0
jne drawpaddleloop

endprintpaddle:
pop di 
pop si 
pop es 
pop cx 
pop bx 
pop ax 
pop es 
pop bp 
ret

movePaddle:
push ax 

in al,0x60

cmp al,77
je arrowRightcheck

cmp al,75
je arrowLeftcheck

jmp nextPlayer

arrowRightcheck:
cmp word [Player2],3960
jb arrowRight
jmp nextPlayer

arrowLeftcheck:
cmp word [Player2],3840
ja arrowLeft
jmp nextPlayer

arrowRight:
add word [Player2],2
call printPaddles
jmp nextPlayer

arrowLeft:
sub word [Player2],2
call printPaddles
jmp nextPlayer

nextPlayer:

in al,0x60

cmp al,32
je wordRightcheck

cmp al,30
je wordLeftcheck

jmp endmovePaddle

wordRightcheck:
cmp word [Player1],120
jb wordRight
jmp endmovePaddle

wordLeftcheck:
cmp word [Player1],0
ja wordLeft
jmp endmovePaddle

wordRight:
add word [Player1],2
call printPaddles
jmp endmovePaddle

wordLeft:
sub word [Player1],2
call printPaddles
jmp endmovePaddle

endmovePaddle:
mov al,0x20
out 0x20,al

pop ax 
iret 

printBall:
push bp 
mov bp,sp 
push ax 
push es 
push di 

mov ax,0xb800
mov es,ax

mov di,[Ball_Location]

mov ax,[es:di]
mov al,0x2A
mov [es:di],ax

pop di
pop es 
pop ax 
pop bp 
ret 


mainPhase:
call clrscrntoBlack
call printPaddles
call printBall

mov ah,0x13
mov al,0x01
mov bh,0x00
mov bl,0x81
mov cx,21
mov dh,12
mov dl,30
push cs
pop es
mov bp,intromsg
int 0x10

waitForEnter:
mov ah, 0x01 
int 0x21            
cmp al, 0x0D       
jne waitForEnter    

call clrscrntoBlack
call printPaddles
call printBall

xor ax,ax
mov es,ax

cli
mov word [es:9*4],movePaddle
mov word [es:9*4+2],cs 
sti 

updatePhase:


displayPhase:


jmp updatePhase

endGame:
mov ax,0x4C00
int 0x21