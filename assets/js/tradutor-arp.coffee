Raphael.st.toArp = () ->
  nodos = "\"nodos\": ["
  estrutura = "\"estrutura\": ["
  @forEach (obj) ->
    if obj.type == 'circle'
      nodos += "[\"#{obj.data('nome')}\", \"#{obj.data('fichas')}\"], "
    else if obj.type == 'rect'
      nodos += "[\"#{obj.data('nome')}\"], "
      estrutura += "{ \"#{obj.data('nome')}\": [["
      if obj.data('lineto')?
        obj.data('lineto').forEach (e) ->
          estrutura += "\"#{e.data('elfrom').data('nome')}\", "
      estrutura = "#{estrutura.replace /(,\s)$/g, ''}], ["
      if obj.data('linefrom')?
        obj.data('linefrom').forEach (e) ->
          estrutura += "\"#{e.data('elto').data('nome')}\", "
      estrutura = "#{estrutura.replace /(,\s)$/g, ''}]]}, "
  estrutura = "#{estrutura.replace /(,\s)$/g, ''}]"



  nodos = "#{nodos.replace /(,\s)$/g, ''}]"
  console.log("{#{nodos}, #{estrutura}}")
  json = jQuery.parseJSON("{#{nodos}, #{estrutura}}")

  string = "REDE PETRINET ;\r\n\r\nNODOS\r\n\r\n"
  $.each json.nodos, () ->
    if @[0][0] == 'P'
      string += "#{@[0]} :\tLUGAR#{if @length == 2 then "(#{@[1]})" else ''} ;\r\n"
    else
      string += "#{@[0]} :\tTRANSICAO ;\r\n"
  string += "\r\nESTRUTURA\r\n\r\n"
  $.each json.estrutura, () ->
    $.each @, (k, v) ->
      string += "#{k} : (#{v[0].join(', ')}), (#{v[1].join(', ')}) ;\r\n"
  string += "\r\nFIM."
  string