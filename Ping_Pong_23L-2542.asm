;Project by Ryyan Choudhary() and Usama Zafar()
;Ping Pong Game in Assembly
[org 0x100]
jmp mainPhase

;Variables
Player1: dw 60
Player2: dw 3900
Paddle_Size: dw 20

Player1score: dw 0
Player2score: dw 0
Score1Location: dw 180
Score2Location: dw 3820

Oldkbisroffset: dw 0
Oldkbisrsegment: dw 0
Oldtimisroffset: dw 0
Oldtimisrsegment: dw 0

Ball_Location: dw 3760
BallX: dw 1 ;1=right, -1=left
BallY: dw 1 ;1=up, -1=down

intromsg: db 'Press enter to start!'



;Functions,Isrs,Tsrs
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



ballTimerIsr:
push ax 

call ballMovement
call printPaddles

push word [Player1score]
push word [Score1Location]
call scorePrinting

push word [Player2score]
push word [Score2Location]
call scorePrinting

mov al,0x20
out 0x20,al
pop ax 
iret



ballMovement:
push bp 
mov bp,sp 
push es 
push ax 
push bx 
push cx 
push es 
push si 
push di

checkCorners:
cmp word [Ball_Location],0
je reverseHV

cmp word [Ball_Location],158
je reverseHV 

cmp word [Ball_Location],3840
je reverseHV 

cmp word [Ball_Location],3998
je reverseHV

jmp checkleftBoundary

reverseHV:
mov ax, [BallX]
imul ax, -1
mov [BallX], ax

mov ax, [BallY]
imul ax, -1
mov [BallY], ax
jmp moveLocation

checkleftBoundary:
mov ax,0 ;start
mov bx,3840  ;end

cmploop1:
cmp ax,bx
je checkrightBoundary

cmp [Ball_Location],ax
je reverseH

add ax,160
jmp cmploop1

checkrightBoundary:
mov ax,158 ;start
mov bx,3998  ;end

cmploop2:
cmp ax,bx
je checkupBoundary

cmp [Ball_Location],ax
je reverseH

add ax,160
jmp cmploop2

reverseH:
mov ax,[BallX]
imul ax,-1
mov [BallX],ax


checkupBoundary:
cmp word [Ball_Location],0
jae checkupBoundary2
jmp checkdownBoundary

checkupBoundary2:
cmp word [Ball_Location],158
jbe reverseV
jmp checkdownBoundary

checkdownBoundary:
cmp word [Ball_Location],3840
jae checkdownBoundary2
jmp moveLocation

checkdownBoundary2:
cmp word [Ball_Location],4000
jbe reverseV
jmp moveLocation

reverseV:
mov ax,[BallY]
imul ax,-1 
mov [BallY],ax

moveLocation:
mov ax,0xb800
mov es,ax
mov si,[Ball_Location]
mov word [es:si],0x0720

initiateMove:
cmp word [BallX],1
je c1 

cmp word [BallX],-1
je c2 

c1:
cmp word [BallY],1
je c11

cmp word [BallY],-1
je c12 

c2:
cmp word [BallY],1
je c21

cmp word [BallY],-1
je c22 

c11:
sub word [Ball_Location],158
jmp printMove

c12:
add word [Ball_Location],162
jmp printMove

c21:
sub word [Ball_Location],162
jmp printMove

c22:
add word [Ball_Location],158
jmp printMove

printMove:
mov si,[Ball_Location]
mov ax,[es:si]
mov al,0x2A
mov [es:si],ax

endballMovement:
pop di 
pop si 
pop es 
pop cx 
pop bx 
pop ax 
pop es 
pop bp 
ret

scorePrinting:
push bp 
mov bp,sp 
push es 
push ax 
push bx 
push cx 
push dx 
push di 

mov ax,0xb800
mov es,ax 
mov ax,[bp+6]
mov bx,10 
mov cx,0 

nd:
mov dx,0
div bx 
add dl,0x30 
push dx 
inc cx 
cmp ax,0
jnz nd

mov di,[bp+4]

np:
pop dx 
mov dh,0x07
mov [es:di],dx 
add di,2 
loop np 

pop di 
pop dx 
pop cx 
pop bx 
pop ax 
pop es 
pop bp
ret 4



;Main game loop
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

mov ax, [es:9*4]
mov [Oldkbisroffset],ax
mov ax, [es:9*4+2]
mov [Oldkbisrsegment], ax

cli
mov word [es:9*4],movePaddle
mov word [es:9*4+2],cs 
sti 

mov ax, [es:8*4]
mov [Oldtimisroffset],ax
mov ax, [es:8*4+2]
mov [Oldtimisrsegment], ax

cli
mov word [es:8*4],ballTimerIsr
mov word [es:8*4+2],cs 
sti

updatePhase:


displayPhase:


jmp updatePhase

endGame:
mov ax,0x4C00
int 0x21