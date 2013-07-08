Raphael.st.toArp = () ->
	nodos = "\"nodos\": ["
	estrutura = "\"estrutura\": "
	@forEach (obj) ->
		if obj.type == 'circle'
			nodos += "[\"P#{obj.id}\", \"#{obj.data('fichas')}\"], "
		else if obj.type == 'rect'
			nodos += "[\"T#{obj.id}\"], "
			estrutura += "{ \"T#{obj.id}\": [["
			if obj.data('lineto')?
				obj.data('lineto').forEach (e) ->
					estrutura += "\"P#{e.data('elto').id}\", "
			estrutura = "#{estrutura.replace /(,\s)$/g, ''}], ["
			if obj.data('linefrom')?
				obj.data('linefrom').forEach (e) ->
					estrutura += "\"P#{e.data('elto').id}\", "
			estrutura = "#{estrutura.replace /(,\s)$/g, ''}]]}"



	nodos = "#{nodos.replace /(,\s)$/g, ''}]"
	jQuery.parseJSON("{#{nodos}, #{estrutura}}")