

model FinalProject

/* Insert your model definition here */


global {
  /* Insert the global definitions, variables and actions here */
  int num_guests <- 50;
  int num_stages <- 5;
  int num_bars <- 2;
  float global_happiness_Introvert <- 0.5;
  float global_happiness_Extrovert <- 0.5;
  float global_happiness_Party <- 0.5;
  float global_happiness_Rock <- 0.5; 
  float global_happiness_Healthy <- 0.5; 
  
  list<string> music_types <- ["Pop", "Rock", "Techno"];
  list<string> person_types <- ["Introvert", "Extrovert", "Party", "Rock", "Healthy"];
  
  list<Stage> stages <- [];
  list<Bar> bars <- [];
  list<Guest> guests <- [];
  
  map<string, float> average_happiness;
  
  init{
    create Introvert number:num_guests/5;
    create Extrovert number:num_guests/5;
    create Party number:num_guests/5;
    create Rock number:num_guests/5;
    create Healthy number:num_guests/5;
    create Stage number:num_stages;
    create Bar number:num_bars;
    
    
    loop i from:1 to:num_stages{
    	add Stage[i-1] to: stages;
    }
    
    loop i from:1 to:num_bars{
    	add Bar[i-1] to: bars;
    }
    
    
    loop i from:1 to:num_guests/5 {
    	Introvert[i-1].pref_music_style <- music_types[ rnd( length(music_types)-1 ) ];
    	Introvert[i-1].generosity <- 0.1;
    	Introvert[i-1].loudness <- 0.0;
    	Introvert[i-1].open_mind <- 0.7;
    	Introvert[i-1].tollerance <- 0.5;
    	Introvert[i-1].person_type <- "Introvert";
    	Introvert[i-1].Ok_drink <- rnd(1.0);
    	
    	Introvert[i-1].happiness <- 0.5;
    	Introvert[i-1].inside_bar <- false;
    	add Introvert[i-1] to: guests;
    	
   }
    
    loop i from:1 to:num_guests/5 {
    	Extrovert[i-1].pref_music_style <- music_types[ rnd( length(music_types)-1 ) ];
    	Extrovert[i-1].generosity <- 0.7 + rnd(0.4);
    	Extrovert[i-1].loudness <- 0.5;
    	Extrovert[i-1].open_mind <- 1.0;
    	Extrovert[i-1].tollerance <- 0.5;
    	Extrovert[i-1].person_type <- "Extrovert";
    	
    	Extrovert[i-1].happiness <- 0.5;
    	Extrovert[i-1].inside_bar <- false;
    	add Extrovert[i-1] to: guests;
    	
    }
    
    loop i from:1 to:num_guests/5 {
    	Party[i-1].pref_music_style <- music_types[ rnd( length(music_types)-1 ) ];	
    	Party[i-1].generosity <- 0.9;
    	Party[i-1].loudness <- 1.0;
    	Party[i-1].open_mind <- 0.5;
    	Party[i-1].tollerance <- 0.5;
    	Party[i-1].person_type <- "Party";
    	
    	Party[i-1].happiness <- 0.5;
    	Party[i-1].inside_bar <- false;
    	add Party[i-1] to: guests;
    	
    }
    
    loop i from:1 to:num_guests/5 {
    	Rock[i-1].pref_music_style <- "Rock";	
    	Rock[i-1].generosity <- 0.4;
    	Rock[i-1].loudness <- 0.85;
    	Rock[i-1].open_mind <- 0.1;
    	Rock[i-1].tollerance <- 0.5;
    	Rock[i-1].person_type <- "Rock";
    	
    	Rock[i-1].happiness <- 0.5;
    	Rock[i-1].inside_bar <- false;
    	add Rock[i-1] to: guests;	
    	
    }
    
    loop i from:1 to:num_guests/5 {
    	
       	Healthy[i-1].pref_music_style <- music_types[ rnd( length(music_types)-1 ) ];	
       	Healthy[i-1].generosity <- 0.5;
    	Healthy[i-1].loudness <- 0.3;
    	Healthy[i-1].open_mind <- 0.8;
    	Healthy[i-1].tollerance <- 0.5;
    	Healthy[i-1].person_type <- "Healthy";
    	Healthy[i-1].pref_bar_type <- "Non-Alcoholic";
    	
    	Healthy[i-1].happiness <- 0.5;
    	Healthy[i-1].inside_bar <- false;
    	add Healthy[i-1] to: guests;	
    }
    
    
    loop i from:1 to:num_stages {
    	
    	add Stage[i-1] to: stages;		
    	
    	Stage[i-1].MusicType <- music_types[ rnd( length(music_types)-1 ) ];
    }
    
    loop i from:1 to:num_bars {
    	
    	add Bar[i-1] to: bars;		
    	
    	if(i = 1){
    		Bar[i-1].BarType <- "Non-Alcoholic";
    	}else{
    		Bar[i-1].BarType <- "Alcoholic";
    	}
    }
    
  // Reflex to periodically update happiness data

  }
}




species Guest skills: [moving, fipa]{
  int crowded_place_number <- 9;
  int uncrowded_place_number <- 5;

  float happiness <- 0.0; 

  point target <- nil;
  string target_type <- nil;
  
  string pref_music_style <- "Unknown";
  string pref_bar_type <- "Unknown";
  float tollerance <- 1.0;
  float Ok_drink <- 0.0;
  
  bool thirsty <- false;
  bool dancing <- false;
  bool inside_bar <- false;
  
  float best_utility <- 0.0;
  Stage best_stage <- nil;
  
  float generosity <- 0.0;
  float loudness <- 0.0;
  float open_mind <- 0.0;
  
  int thirsty_countdown <- rnd(50, 80);
  int socialize_countdown <- rnd(20, 50);
  
  string person_type <- "Unknown";
  
  reflex receiveMsgs when: !empty(queries){
  	loop queryMsg over: queries{
  		if(queryMsg.contents[0] = "Drink?"){
  			write "I, " + name + " received a drink offer from " + queryMsg.sender;
  			
  			if(person_type = "Party"){//Thanking for the drink!
  				do update_happiness(0.1);
  			}
  			
  			if(self.Ok_drink > 0.6 or (person_type = "Healthy" and target_type = "Non-Alcoholic")){
  				write name + " accepts drink";
  				do update_happiness(0.1);
  				
  				if( person_type = "Healthy" ){
  					do update_happiness(0.1);
  				}
  				
  				self.thirsty <- false;
  				
  				self.inside_bar <- false;
  				socialize_countdown <- rnd(20, 50);
  				
  				do agree message: queryMsg contents: [];	
  			}else{
  				write name + " refuses drink";
  				
  				if(person_type = "Healthy"){
  					do update_happiness(-0.1);
  				}
  				
  				do refuse message: queryMsg contents: [];
  			}
  		}
  	}
  }
  
  reflex receiveAgree when: !empty(agrees){
  	loop agreeMsg over: agrees{
  		write "I, " + name + " received an agree message from " + agreeMsg.sender;
 
  		do update_happiness(0.1);
  		string dummy <- agreeMsg.contents;
  		//increase happiness
  	}
  }
  
  reflex receiveRefuse when: !empty(refuse){
  	loop refuseMsg over: refuses{
  		write "I, " + name + " received a refuse message from " + refuseMsg.sender;
  		
  		do update_happiness(-0.1);
  		//decrease happiness
  		string dummy <- refuseMsg.contents;
  	}
  }
  
  action update_happiness(float factor){
  		self.happiness <- self.happiness + factor;
  		switch person_type{
	  		match 'Introvert' {
	  			global_happiness_Introvert <- global_happiness_Introvert + factor;
	  			if(global_happiness_Introvert >= 1.0){
	  				global_happiness_Introvert <- 1.0;
	  			}else if(global_happiness_Introvert <= 0.0){
	  				global_happiness_Introvert <- 0.0;
	  			}
	  		}
	  		match 'Extrovert' {
	  			global_happiness_Extrovert <- global_happiness_Extrovert + factor;
	  			if(global_happiness_Extrovert >= 1.0){
	  				global_happiness_Extrovert <- 1.0;
	  			}else if(global_happiness_Extrovert <= 0.0){
	  				global_happiness_Extrovert <- 0.0;
	  			}
	  		}
	  		match 'Party' {
	  			global_happiness_Party <- global_happiness_Party + factor;
	  			if(global_happiness_Party >= 1.0){
	  				global_happiness_Party <- 1.0;
	  			}else if(global_happiness_Party <= 0.0){
	  				global_happiness_Party <- 0.0;
	  			}
	  		}
	  		match 'Rock' {
	  			global_happiness_Rock <- global_happiness_Rock + factor;
	  			if(global_happiness_Rock >= 1.0){
	  				global_happiness_Rock <- 1.0;
	  			}else if(global_happiness_Rock <= 0.0){
	  				global_happiness_Rock <- 0.0;
	  			}
	  		}
	  		match 'Healthy' {
	  			global_happiness_Healthy <- global_happiness_Healthy + factor;
	  			if(global_happiness_Healthy >= 1.0){
	  				global_happiness_Healthy <- 1.0;
	  			}else if(global_happiness_Healthy <= 0.0){
	  				global_happiness_Healthy <- 0.0;
	  			}
	  		}
  		}
  }
  
  reflex go_to_stage when: (dancing = false and thirsty = false and target = nil and self.inside_bar = false) {
  	Stage s <- stages at rnd( length(stages)-1 );
	target <- s.location; 
	target_type <- s.MusicType;
    
    loop stage over:stages{
    	if( stage.MusicType = pref_music_style ){
    		target <- stage.location;
    		target_type <- stage.MusicType;
    	}
    }
  }
  
  reflex go_to_bar when: (dancing = false and thirsty = true and target = nil and self.inside_bar = false) {
	Bar s <- bars at rnd( length(bars)-1 );
	target <- s.location; 
	target_type <- s.BarType;
  }
  
  reflex goPlaces when: target != nil{
  	do goto target: target;
  	
  	if(self.location = target){
  		target <- nil;
  		
  		if(thirsty = false){
	  		dancing <- true;
	  	}else{
	  		self.inside_bar <- true;
	  		//write(name + " has arrived at the bar.");
	  		
	  	}
  		
  		//happiness <- calculate_happiness();
  		

  	}
  	
}
  
  reflex idle when: target = nil{
  	happiness <- calculate_happiness();
  }
  
  reflex update_socialize_countdown when: self.inside_bar = true {
  	socialize_countdown <- socialize_countdown - 1;
  	
  	if(socialize_countdown = 0){
  		thirsty <- false;
  		self.inside_bar <- false;
  		//write name + " not thirsty anymore, going to socialize";
  		socialize_countdown <- rnd(20, 50);
  	}
  }
  
  reflex update_thirsty_countdown when: thirsty = false {
  	thirsty_countdown <- thirsty_countdown - 1;
  	
  	if(thirsty_countdown = 0){
  		//write name + " and I am thirsty";
  		thirsty <- true;
  		dancing <- false;
  		
  		thirsty_countdown <- rnd(50, 80);
  	}
  }
  
  list<Guest> retrieve_neighbors {
  	int distance <- 5;
  	
  	list<Guest> neighbors <- Introvert at_distance(distance);
  	neighbors <- neighbors + Extrovert at_distance(distance);
  	neighbors <- neighbors + Healthy at_distance(distance);
  	neighbors <- neighbors + Rock at_distance(distance);
  	neighbors <- neighbors + Party at_distance(distance);
  	
  	return neighbors;
  }
  
  bool calculateStageUtility(string MusicStyle){
  	
	if (MusicStyle = pref_music_style){
		return true;
	}else{
		return false;
	}
  }
  
  action calculate_happiness virtual: true type: float;
	
  // End 	
  
}


species Extrovert parent: Guest{  
	
  bool increaseHappiness <- false;
  bool decreaseHappiness <- false;
  aspect base {
  	rgb AgentColor <- rgb("blue");
    
    draw circle(1) color: AgentColor;
  }
  reflex receive_inform when: !empty(informs){
  	
  	loop informMsg over:informs {
  		
  	}
  
  }
  
  float calculate_happiness{
  	// check where I am
  	
  		if( target_type = pref_music_style ){//if I am at my fav concert
			do update_happiness(0.1);
			write name + " and my happiness increased to " + self.happiness;
			// check if I want to stay in the concert tollerance	
		}
  	
  	list<Guest> neighbors <- retrieve_neighbors();
  	
  	write "List neighbors1: " + neighbors;
  	
	if(length(neighbors) > crowded_place_number){ //Likes Crowded places
		write name + " and my happiness increased to " + self.happiness;
		do update_happiness(0.15);
		
	}else if(length(neighbors) < uncrowded_place_number){
		write name + " and my happiness decreased to " + self.happiness;
		do update_happiness(-0.1);		
	}
  
  	if(length(neighbors) >= 1){
  		if(self.inside_bar){
	  			//write "I am at a bar";
	  			if (self.generosity > 0.9){
	  				do update_happiness(0.1);
		  			write "I, " + name + " am feeling generous, let me offer you a drink";
		  			do start_conversation to: neighbors protocol:'no-protocol' performative: 'query' contents: ["Drink?"];
		  		}	
	  		}else{
	  			//write("I am a party");
	  		}	
  	}
  	
  	
  	
  	// check if I got a drink
  	
  	return happiness;
  }
  
}

species Introvert parent: Guest{  
  
  aspect base {
  	rgb AgentColor <- rgb("green");
    
    draw circle(1) color: AgentColor;
  }
  reflex receive_inform when: !empty(informs){
  	
  	loop informMsg over:informs {
  		
  	}
  
  }
  
  float calculate_happiness{
  	
  	// check people around me
  	
  		list<Guest> party_neighbors <- Party at_distance(5);
	  	//write "List neighbors: " + neighbors;
	  	
	  	if( target_type = pref_music_style ){//if I am at my fav concert
			do update_happiness(0.1);
			write name + " and my happiness increased to " + self.happiness;
			// check if I want to stay in the concert tollerance	
		}
		
		list<Guest> all_neighbors <- retrieve_neighbors();
	  	//list<Guest> neighbors <- Introvert at_distance(5);
	  	
		if(length(all_neighbors) > crowded_place_number){//Likes Crowded places
			write name + " and my happiness increased to " + self.happiness;
			do update_happiness(-0.1);
			
		}else if(length(all_neighbors) < uncrowded_place_number){
			write name + " and my happiness decreased to " + self.happiness;
			do update_happiness(0.15);		
		}
	  	
	  	if(length(party_neighbors) >= 1){
	  		loop i from:1 to:length(party_neighbors){
		  		Guest neighbor <- party_neighbors at (i-1);

		  		if(self.inside_bar){
		  			//if(neighbor.loudness > self.tollerance){
		  				do update_happiness(-0.05);
		  				write name + " and my happiness decreased to " + self.happiness;
		  			//}
		  		}
		  	}
	  	}
	  	return happiness;	
  	}
  }
  

species Rock parent: Guest{  
  
  aspect base {
  	rgb AgentColor <- rgb("black");
    
    draw circle(1) color: AgentColor;
  }
  

  reflex receive_inform when: !empty(informs){
  	
  	loop informMsg over:informs {
  		
  	}
  
  }
  
  float calculate_happiness{
  	
  	list<Guest> rock_neighbors <- Rock at_distance(5);
  	//list<Guest> pop_neighbors <- Healthy at_distance(5);
  	list<Guest> all_neighbors <- retrieve_neighbors();
  	
	if( target_type = pref_music_style ){//if I am at my fav concert
		do update_happiness(0.1);
		write name + " and my happiness increased to " + self.happiness;
		// check if I wan\	at to stay in the concert tollerance
		if(length(all_neighbors) >= 1){
			loop i from:1 to:length(all_neighbors){
		  		Guest neighbor_i <- all_neighbors at (i-1);

		  		if(self.inside_bar){ //I can't hear the music if they are loud
		  			if(neighbor_i.loudness > self.tollerance){
		  				do update_happiness(-0.1);
		  				write name + " and my happiness decreased to " + self.happiness;
		  			}
		  		}
		  	}
		}
	}
	
	if(length(rock_neighbors) >= 2){//if around Rock ppl
		do update_happiness(0.1);
		write name + " and my happiness increased to " + self.happiness;
	}
	
  	if(self.target_type = "Pop"){
  		do update_happiness(-0.2);
  		write name + " buuuu I am at a pop concert";
  	}
  	
  	if(self.target_type = "Non_Alcoholic"){
  		do update_happiness(-0.15);
  		write name + " non-alcoholic bar";
  	}
  	
  	list<Guest> healthy_neighbors <- Healthy at_distance(5);
  	if(length(healthy_neighbors) >= 2){//if around Healthy ppl
		do update_happiness(-0.1);
		write name + " and my happiness increased to " + self.happiness;
	}
  	
  	
  	return happiness;
  }
  
}

species Party parent: Guest{  
  
  aspect base {
  	rgb AgentColor <- rgb("red");
    
    draw circle(1) color: AgentColor;
  }

  
   reflex receiveMsgs_Positioning when: !empty(queries){
  	loop query_msg over:queries{
  		if(query_msg.contents[0] = "Drink?"){
  			write "--------------------I, " + name + " was invited for a drink";
  			
  		}
  	}
  }
  reflex receive_inform when: !empty(informs){
  	
  	loop informMsg over:informs {
  		
  	}
  
  }
  
  float calculate_happiness{
  	
  	list<Guest> all_neighbors <- retrieve_neighbors();
  	
  	if(length(all_neighbors) >= 1){
			loop i from:1 to:length(all_neighbors){
		  		Guest neighbor_i <- all_neighbors at (i-1);

		  		//if(self.inside_bar){ //I can't hear the music if they are loud
		  			if(neighbor_i.loudness > self.tollerance){
		  				do update_happiness(0.05); // happy to be around loud people
		  				write name + " and my happiness decreased to " + self.happiness;
		  			}else if(neighbor_i.loudness < (self.tollerance-0.15)){
		  				do update_happiness(-0.05); 
		  			}
		  		//}
		  	}
		}
  	
  	list<Healthy> healthy_neighbors <- Healthy at_distance(5);
  	
  	if(length(healthy_neighbors) >= 1){
		write name + " and I am with healthy ppl";
		do update_happiness(-0.1);
	}
	
	if(!(inside_bar)){//at a disco
		do update_happiness(0.1);
	}else if(inside_bar and target_type != "Non-Alcoholic"){
		do update_happiness(0.1);//if they are at a no alcaholic bar, decrease happiness
	}
  	
  	return happiness;
  }
  
}

species Healthy parent: Guest{  
  
  aspect base {
  	rgb AgentColor <- rgb("pink");
    
    draw circle(1) color: AgentColor;
  }
  reflex receive_inform when: !empty(informs){
  	
  	loop informMsg over:informs {
  		
  	}
  
  }
  
  float calculate_happiness{
  	
  	list<Guest> neighboors<- Healthy at_distance(5);
  	if(length(neighboors) >= 1){
  		do update_happiness(0.1);  // happy to be around Healthy people
  	}
  	
  	if(inside_bar and target_type = pref_bar_type){
  		do update_happiness(0.1);  // happy to be in alcohol free bar
  	}else if(inside_bar){
  		do update_happiness(-0.1);
  	}
  	
  	list<Guest> all_neighbors <- retrieve_neighbors(); 
  	if(length(all_neighbors) >= 1){
			loop i from:1 to:length(all_neighbors){
		  		Guest neighbor_i <- all_neighbors at (i-1);

		  		if(!self.inside_bar){ //I can't hear the music if they are loud
		  			if(neighbor_i.loudness > self.tollerance){
		  				do update_happiness(-0.05); // happy to be around loud people
		  				write name + " and my happiness decreased to " + self.happiness;
		  			}
		  		}
		  	}
		}
  	
  	return happiness;
  }
  
}

species Bar skills:[fipa]{
	string BarType <- "Unknown";
	
	aspect base {
		
		rgb AgentColor <- rgb("black");
		
		switch BarType{
	    	match "Alcoholic"{
	    		AgentColor <- rgb("black");
	    	}
	    	
	    	match "Non-Alcoholic"{
	    		AgentColor <- rgb("yellow");
	    	}
	    	
	    	default{
	    		AgentColor <- rgb("grey");
	    	}
	    }
	    
	    draw triangle(10) color: AgentColor;	
  	}
  	
}

species Stage skills:[fipa] {
	int act_countdown <- rnd(300, 800);
	
	string MusicType <- "Unknown";
	
	aspect base {
		
		rgb AgentColor <- rgb("black");
	    
	    switch MusicType{
	    	match "Pop"{
	    		AgentColor <- rgb("pink");
	    	}
	    	
	    	match "Rock"{
	    		AgentColor <- rgb("black");
	    	}
	    	
	    	match "Techno"{
	    		AgentColor <- rgb("grey");
	    	}
	    	
	    	default{
	    		AgentColor <- rgb("yellow");
	    	}
	    }
	    
	    draw hexagon(10) color: AgentColor;	
		
  	}
  	
  	reflex receive_queries when: !empty(queries){
  		
  	}
  	
  	reflex receive_subscriptions when: (!empty(subscribes) and (act_countdown = 0)){
  	
  	}
  	
  	reflex updateCountdown {
  		// act_countdown <- act_countdown - 1;
  	}
}


experiment Assignment3 type: gui {
  /** Insert here the definition of the input and output of the model */
  output {
    display MyDisplay {
      species Introvert aspect:base;
      species Extrovert aspect:base;
      species Party aspect:base;
      species Rock aspect:base;
      species Healthy aspect:base;
      species Stage aspect: base;
      species Bar aspect: base;
    }
    
    display HappinessChart {
            chart "Average Happiness by Type" type: series style: spline {
                data "Introvert Happiness" value: (global_happiness_Introvert*10/(num_guests/5)) color: #green;
                data "Extrovert Happiness" value: (global_happiness_Extrovert*10/(num_guests/5)) color: #blue;
                data "Party Happiness" value: (global_happiness_Party*10/(num_guests/5)) color: #red;
                data "Rock Happiness" value: (global_happiness_Rock*10/(num_guests/5)) color: #black;
                data "Healthy Happiness" value: (global_happiness_Healthy*10/(num_guests/5)) color: #pink;
            }
        }
    display TotalHappinessChart{
    		chart "Total Happiness" type: series style: spline {
    			data "Total Happiness" value: ((global_happiness_Introvert+global_happiness_Extrovert+global_happiness_Party+global_happiness_Rock+global_happiness_Healthy)/num_guests);
    		}
    }
  }
}