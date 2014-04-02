exports.action = function(data, callback, config, manager) {
	
	// Sarah => HomeSeer_REST_API.aspx
	// Voir ici pour installer l'API et lire sa documentation : http://board.homeseer.com/showthread.php?t=163200 - 
	// Pour ce plugin je suis parti du plugin homeseer fait par Jérôme VEYRET.
	// Ceci est la version 1.0 - Uniquement lancer un event par son nom ou controler un device par son id
	// Amélioration en cours pour la version 1.1 : Lancer des scripts via une version modifiée de l'API
	// Pour la version finale j'aimerai utiliser intégralement l'API - Par exemple on devrait pouvoir récupérer la valeur d'un device et le faire vocaliser par Sarah.




	if ( typeof(data.fonction) != "undefined" ) {
		config = config.modules.HS3;
		// Build URL:
		var url=config.HS3_IP+":"+config.HS3_Port+ config.HS3_API + "?function=" + data.fonction +"&param1=" + data.param1 + "&param2=" + data.param2 + "&param3=" + data.param3;
		console.log("HS3 plugin:" + url);
 
		// Send Request
		var request = require('request');
		request({ 'uri' : url }, function (err, response, body){
			if (err || response.statusCode != 200) {
				callback({'tts': "Action impossible, je ne communique pas avec HomeSeer"});
				return;
				}
			callback(); // Le compte rendu "c'est fait" ou "OK" (ou...) se fera par HS3 Vers Sarah avec le plugin Parle
		});	
	}
	
}

