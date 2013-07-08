#= require tradutor-arp
#= require lugar
#= require transicao
#= require core
#= require drag
#= require el_events

@RAIO = 20
@LARGURA = 50
@ALTURA = LARGURA/3
@CANVAS_LARGURA = $(window).innerWidth()
@CANVAS_ALTURA = $(window).innerWidth() * 3/4

@paper = null
@objetos = null
@band = null


@x = 0
@y = 0
@oldid = 0
@oldx = 0
@oldy = 0
@numT = 1
@numP = 1
@bg = null