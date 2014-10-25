package  {
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.*;
	import flash.xml.*;
	import flash.text.TextField;
	import flash.sampler.NewObjectSample;
	import flash.globalization.DateTimeFormatter;
	import flash.display3D.IndexBuffer3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class weather extends MovieClip{

		var stage1:MovieClip;
		var myXML:XML;
		var cloudArray:Array = [];
		var weekDays:Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		var dayArray:Array = [];
		var bgArray:Array = [];
		var date:Date;
		var oldCity:String;
		var localObject:SharedObject = SharedObject.getLocal("localObjectID");
		
		public function weather() {
			stage1 = new stage_mc;
			var up = new edit_btn;
			addChild(stage1);
			stage1.save_btn.addEventListener(MouseEvent.CLICK, changeWeather);
			SetWeatherStage();
			GetXMLData();
			
			/* Sets weather bg array */
			bgArray[0] = stage1.daybg_mc.daybg2_mc;
			bgArray[1] = stage1.daybg_mc.nightbg_mc;
			bgArray[2] = stage1.daybg_mc.cloudybg2_mc;
			bgArray[3] = stage1.daybg_mc.snowbg3_mc;
			
			
			var displace:Number= 200;
			up.x = stage.x/2 - displace;
			up.y = stage.y +360;
			up.addEventListener(MouseEvent.CLICK, panScene);
			var down = new back_btn;
			down.x = stage.x/2;
			down.y = stage.y - 380;
			down.addEventListener(MouseEvent.CLICK, panDown);
		
			stage1.addChild(up);
			stage1.addChild(down);
			stage1.save_btn.addEventListener(MouseEvent.CLICK, storeData);
			//stage1.addEventListener(Event.ENTER_FRAME, stopFrame);
			for(var i:Number = 1; i < 7; i++){
				stage1["day" + i].addEventListener(MouseEvent.CLICK, swap);
			}
			//testRain();
		}
		
		public function panScene(e:Event):void{
				
			var cloud:MovieClip;
			var cloud2:MovieClip;
			var cloud3:MovieClip;
			for(var j:Number=0, num:Number=0; j <800; j+=200, num++){
				cloud = new cloud1;
				cloud2 = new cloud1;
				cloud3 = new cloud1;
				cloud.x = j;
				cloud.y= (-1 * j)-200;
				
				cloudArray.push(cloud);
				//trace(cloudArray[cloud + ""]);
				stage1.addChild(cloud);
				
				cloud2 = new cloud1;
				cloud2.x = j-200;
				cloud2.y= (-1 * j)-400;
				stage1.addChild(cloud2);
				
				cloudArray.push(cloud2);
				
				cloud3 = new cloud1;
				cloud3.x = j+500;
				cloud3.y= (-1 * j)-200;
				stage1.addChild(cloud3);
				
				cloudArray.push(cloud3);
			}
			addEventListener(Event.ENTER_FRAME,followBall);
			
			for(var i:Number=0; i < 900; i++){
				stage1.y++;
			}
		}
		
		public function panDown(e:Event):void{
			
			for(var cloud:Number = cloudArray.length-1; cloud >= 0; cloud--){

				stage1.removeChild(cloudArray[cloud]);
				cloudArray.splice(cloudArray.indexOf(cloud),1);
				stage1.removeEventListener(Event.ENTER_FRAME, followBall);
				
			}
			for(var i:Number = 0; i < 900; i++){
				stage1.y--;
			}
		}
		
		public function followBall(e:Event):void{
			
			for(var cloud:String in cloudArray){
				var mousediff_x:Number = cloudArray[cloud].x - mouseX;
				//if((cloudArray[cloud].x -= mousediff_x/700))
				cloudArray[cloud].x -= mousediff_x/700;
				//if(cloudArray[cloud].x +200 )
			}
			
		}
		
		public function SetWeatherStage():void{
			var name2:String;
			var xLocation:Number = 125;
			var weat_h:Number = 150.05;
			var weat_w:Number = 99.05;
			var weekHeight:Number = 715;
			for(var i:Number = 0; i < 7; i++){
				name2 = "day" + i;
				
				if(i == 0){
					
					dayArray[name2] = new big_mc;
					dayArray[name2].x = 150.35;
					dayArray[name2].y = 237.45;
					dayArray[name2].height = 480;
					dayArray[name2].width = 960;
					
				}
				else if(i == 1){
					
					dayArray[name2] = new small_mc;
					dayArray[name2].x = xLocation;
					dayArray[name2].y = weekHeight;
					dayArray[name2].height = weat_h;
					dayArray[name2].width = weat_w;
				
				}
				else{
					xLocation += 170;
					dayArray[name2] = new small_mc;
					dayArray[name2].x = xLocation;
					dayArray[name2].y = weekHeight;
					dayArray[name2].height = weat_h;
					dayArray[name2].width = weat_w;
					
				}
				dayArray[name2].name = name2;
				stage1.addChild(dayArray[name2]);
			}
			dayArray.length = 7;
		}
		
		public function GetXMLData():void{
			
			var url:String;
			if(localObject.data.cityURL != null){
				url = localObject.data.cityURL;
				stage1.City_text.text = localObject.data.city +"";
				stage1.City_text2.text = localObject.data.city +"";
			}
			else{
				url = "http://api.openweathermap.org/data/2.5/forecast/daily?q=Salt+Lake+City,UT&mode=xml&units=imperial&cnt=7";
				stage1.City_text.text = "Salt Lake City";
				stage1.City_text2.text = "Salt Lake City";
			}
		
		var file:URLRequest = new URLRequest(url);
		var myLoader:URLLoader = new URLLoader();
		myLoader.load(file);
		myLoader.addEventListener(Event.COMPLETE, processXML);

		}
		
		function processXML(e:Event):void {
		
		myXML = new XML(e.target.data);
			showDay();
		}
		
		function showDay():void{

			/*
				1= Sunny,
				2= Rain,
				3= Thunder,
				4= Partly Cloudy,
				5= Snowing,
				6= Cloudy
			*/
			
			for(var i:Number = 0; i < dayArray.length; i++){
				var theDay = "day" + (i);
				var num:Number = parseWeather(i);
				dayArray[theDay].gotoAndStop(num);
				if(i == 0){
					
					switch(num){
						case 1:
								bgArray[0].alpha = 0;
								stage1.addEventListener(Event.ENTER_FRAME, function(e:Event):void{
								changeBack(e, arguments.callee, 0);
							});
						break;
						
						case 2:
								bgArray[1].alpha = 1;
								stage1.addEventListener(Event.ENTER_FRAME, function(e:Event):void{
								changeStage(e, arguments.callee, 1);
							});
						break;
						
						case 3:
									bgArray[1].alpha = 1;
									stage1.addEventListener(Event.ENTER_FRAME, function(e:Event):void{
								changeStage(e, arguments.callee, 1);
							});
						break;
						
						case 4:
									bgArray[0].alpha = 1;
									bgArray[1].alpha = 1;
									bgArray[2].alpha = 1;
									stage1.addEventListener(Event.ENTER_FRAME, function(e:Event):void{
								changeBack(e, arguments.callee,2);
							});
						break;
						
						case 5:
									bgArray[0].alpha = 1;
									bgArray[1].alpha = 1;
									bgArray[2].alpha = 1;
									stage1.addEventListener(Event.ENTER_FRAME, function(e:Event):void{
								changeStage(e, arguments.callee, 3);
							});
						break;

						case 6:
									bgArray[0].alpha = 1;
									bgArray[1].alpha = 1;
									bgArray[2].alpha = 1;
									stage1.addEventListener(Event.ENTER_FRAME, function(e:Event):void{
								changeBack(e, arguments.callee, 2);
							});
						break;
						
						default:
							stage1.error_txt.text = "Error!!";
						break;
					}
				}
			}
			
			for(var j:Number = 1; j < dayArray.length; j++){
				if(dayArray["day" +j].sunny_mc !=null){
				dayArray["day" +j].sunny_mc.gotoAndStop(1);}
				else if(dayArray["day" +j].partly_mc !=null){
				dayArray["day" +j].partly_mc.gotoAndStop(20);}
				else if(dayArray["day" +j].cloudy_mc !=null){
				dayArray["day" +j].cloudy_mc.sun_mc.gotoAndStop(1);}
				else if(dayArray["day" +j].rainy_mc !=null){
					/*trace('get here!');
					trace(dayArray["day" +j].rainy_mc.rain_mc);
					var myRoot:MovieClip = MovieClip(root);
					myRoot.gotoAndStop(4); */
					dayArray["day" +j].rainy_mc.raining_mc.gotoAndStop(15);
					}
				else if(dayArray["day" +j].thunder_mc !=null){
				dayArray["day" +j].thunder_mc.light_mc.gotoAndStop(10);}
				else if(dayArray["day" +j].snow_mc !=null){
				dayArray["day" +j].snow_mc.snow_mc3.gotoAndStop(1);}
			}
			
			//todaysDay();
		}
		
		function parseWeather(y:Number):Number{
			var dateText:String;
			var weather2:String;
			var min:String;
			var max:String;
			var breeze:String;
			var wind:String;
			var humidity:String;
			var winddir:String;
			var wCode:Number;
			var theName:String = "day" + y;
		
			if(myXML != null){
				stage1.error_txt.text = "";
				stage1.City_text.text = myXML.location.name;
				stage1.City_text2.text = stage1.City_text.text;
				if(myXML.forecast != undefined){
				dateText = myXML.forecast.time[y].@day;
				var year:String = dateText.substr(0,4);
				var month:String = dateText.substring(5,7);
				var day:String = dateText.substr(8, 9);
				date = new Date((month+"/"+day+"/"+year));
				dateText = dateText.substr(5);
				breeze = myXML.forecast.time[(y)].windSpeed.@name;
				wind = myXML.forecast.time[(y)].windSpeed.@mps + " mps";
				humidity = myXML.forecast.time[(y)].humidity.@value + "" + myXML.forecast.time[(y)].humidity.@unit;
				winddir = myXML.forecast.time[(y)].windDirection.@code;
				min = myXML.forecast.time[y].temperature.@min + "°F" ;
				max =  myXML.forecast.time[y].temperature.@max + "°F";
					
					if(myXML.forecast.time[(y)].precipitation.@type.length() > 0){
						
						var type2:String = myXML.forecast.time[y].precipitation.@type;
						switch(type2){
						case "snow":
							wCode = 5;
							weather2 = "Snow and " + myXML.forecast.time[y].clouds.@value;
							break;
						case "rain":
							wCode = 2;
							weather2 = "Rain and " + myXML.forecast.time[y].clouds.@value;
							break;
						
						}
					}
					else{
					weather2 = myXML.forecast.time[y].clouds.@value;
					var forecastCode:Number =  Number(myXML.forecast.time[y].symbol.@number);
					//trace(maxNum < 80 && maxNum > 20 );
							
							if(weather2.indexOf("clear") >= 0){
								wCode = 1;
							}
							else if(weather2.indexOf("scattered") >= 0 || weather2.indexOf("broken") >= 0){
								wCode = 6;
							}
							else if(weather2.indexOf("cloud") >= 0){
								wCode = 4;
							}
							else if(forecastCode >= 200 && forecastCode < 300){
								
								wCode = 3;
							}
							else if(forecastCode < 400 && forecastCode>= 300 ){
								
								wCode = 4;
							}
							else if(forecastCode >= 500 && forecastCode < 600){
								
								wCode = 6;
							}
							else if(forecastCode >= 600 && forecastCode < 700){
								wCode=5;
							}
							else if(forecastCode == 801 || forecastCode == 800){
								wCode = 1;
							}
							else if(forecastCode>=803){
								wCode = 6;
							}
							else{
								wCode = 4;
							}
							
							if(weather2.indexOf("overcast") >= 0)wCode = 3;
						
					} 
					
					if(y == 0){
					dayArray["day"+y].Min_txt.text = min;
					dayArray["day"+y].Max_txt.text = max;
					dayArray["day"+y].Weather_txt.text = weather2;
					dayArray["day"+y].Date_txt.text = dateText;
					dayArray["day"+y].Humidity_txt.text = humidity;
					dayArray["day"+y].Wind_txt.text = wind;
					dayArray["day"+y].WindDir_txt.text = winddir;
					dayArray["day"+y].Breeze_txt.text = breeze;
					
					}
					else{
					dayArray[theName].MinText = min;
					dayArray[theName].MaxText = max;
					dayArray[theName].DateText = dateText;
					dayArray[theName].WeatherText = weather2;
					dayArray[theName].HumidityText = humidity;
					dayArray[theName].WindText = wind;
					dayArray[theName].WindDirText = winddir;
					dayArray[theName].BreezeText = breeze;
					
					}
	
					dayArray[theName].Day_txt.text = weekDays[date.day];
					dayArray[("day"+y)].weatherCode = wCode;
				}
				else{
					stage1.error_txt.text = "City not found.";
					localObject.data.city = oldCity;
					stage1.City_text.text = oldCity;
					stage1.City_text2.text = oldCity;
					trace(localObject.data.city);
					localObject.data.cityURL = "http://api.openweathermap.org/data/2.5/forecast/daily?q="+oldCity+"&mode=xml&units=imperial&cnt=7&nocache="+ new Date().getTime();
					localObject.flush();
				}
			}
			else{
				trace("Caught exception");
			}
			
		
			
		return wCode;
	}
	
		public function changeWeather(e:Event):void{
			
		var inject:String = stage1.stored_txt.text;
		var file:URLRequest = new URLRequest("http://api.openweathermap.org/data/2.5/forecast/daily?q="+inject+"&mode=xml&units=imperial&cnt=7&nocache="+ new Date().getTime());
		var myLoader:URLLoader = new URLLoader();
		myLoader.load(file);
		myLoader.addEventListener(Event.COMPLETE, processXML);
		}
		
			public function storeData(e:Event):void{
			
			oldCity = localObject.data.city;
			var inject:String = stage1.stored_txt.text;
			localObject.data.city = stage1.stored_txt.text;
			localObject.data.cityURL = "http://api.openweathermap.org/data/2.5/forecast/daily?q="+inject+"&mode=xml&units=imperial&cnt=7&nocache="+ new Date().getTime();
			localObject.flush();
			}
			
			function swap(e:Event):void{
				swapWeather(e.target.name, "day0");
			}
			
	function swapWeather(oldDay:String, newDay:String):void{
			var tempDay:MovieClip = new small_mc;
			tempDay.Day_txt.text = dayArray[newDay].Day_txt.text;
			tempDay.MinText = dayArray[newDay].Min_txt.text;
			tempDay.MaxText = dayArray[newDay].Max_txt.text;
			tempDay.WeatherText = dayArray[newDay].Weather_txt.text;
			tempDay.DateText = dayArray[newDay].Date_txt.text;
			tempDay.HumidityText = dayArray[newDay].Humidity_txt.text;
			tempDay.WindText = dayArray[newDay].Wind_txt.text;
			tempDay.WindDirText = dayArray[newDay].WindDir_txt.text;
			tempDay.BreezeText = dayArray[newDay].Breeze_txt.text;
			tempDay.weatherCode = dayArray[newDay].weatherCode;
			
			dayArray[newDay].Day_txt.text = dayArray[oldDay].Day_txt.text;
			dayArray[newDay].Min_txt.text = dayArray[oldDay].MinText;
			dayArray[newDay].Max_txt.text = dayArray[oldDay].MaxText;
			dayArray[newDay].Weather_txt.text = dayArray[oldDay].WeatherText;
			dayArray[newDay].Date_txt.text = dayArray[oldDay].DateText;
			dayArray[newDay].Humidity_txt.text = dayArray[oldDay].HumidityText;
			dayArray[newDay].Wind_txt.text = dayArray[oldDay].WindText;
			dayArray[newDay].WindDir_txt.text = dayArray[oldDay].WindDirText;
			dayArray[newDay].Breeze_txt.text = dayArray[oldDay].BreezeText;
			dayArray[newDay].weatherCode = dayArray[oldDay].weatherCode;
			dayArray[newDay].gotoAndStop(dayArray[oldDay].weatherCode);

			dayArray[oldDay].Day_txt.text = tempDay.Day_txt.text;
			dayArray[oldDay].MinText = tempDay.MinText;
			dayArray[oldDay].MaxText = tempDay.MaxText;
			dayArray[oldDay].WeatherText = tempDay.WeatherText;
			dayArray[oldDay].DateText = tempDay.DateText;
			dayArray[oldDay].HumidityText = tempDay.HumidityText;
			dayArray[oldDay].WindText = tempDay.WindText;
			dayArray[oldDay].WindDirText = tempDay.WindDirText;
			dayArray[oldDay].BreezeText = tempDay.BreezeText;
			
			dayArray[oldDay].weatherCode = tempDay.weatherCode;
			dayArray[oldDay].gotoAndStop(tempDay.weatherCode);
			
				/*trace(dayArray[oldDay].sunny_mc);
				trace(dayArray[oldDay].partly_mc);
				trace(dayArray[oldDay].rainy_mc.rain_mc);
				trace(dayArray[oldDay].cloudy_mc);
				trace(dayArray[oldDay].thunder_mc.light_mc);
				trace(dayArray[oldDay].snowy_mc); */
				if(dayArray[oldDay].sunny_mc !=null){
				dayArray[oldDay].sunny_mc.gotoAndStop(1);}
				else if(dayArray[oldDay].partly_mc !=null){
				dayArray[oldDay].partly_mc.gotoAndStop(20);}
				else if(dayArray[oldDay].cloudy_mc !=null){
				dayArray[oldDay].cloudy_mc.sun_mc.gotoAndStop(1);}
				else if(dayArray[oldDay].rainy_mc !=null){
				dayArray[oldDay].rainy_mc.raining_mc.gotoAndStop(10);}
				else if(dayArray[oldDay].thunder_mc !=null){
				dayArray[oldDay].thunder_mc.gotoAndStop(10);}
				else if(dayArray[oldDay].snowy_mc !=null){
				dayArray[oldDay].snowy_mc.snow_mc2.gotoAndStop(1);} 
			
			}
			
			function changeStage(e:Event, fct:Function, num:Number):void{
				
				if(num > 1){
					for(var x:Number = 0; x < num; x++){
						bgArray[x].alpha -= .1;
						if(bgArray[num-1].alpha <= 0){
						stage1.gotoAndStop(1);
						stage1.removeEventListener(e.type, fct);
						}
						
					}
				}
				else{
					bgArray[0].alpha -= 0.1;
					if(bgArray[0].alpha <= 0){
						stage1.gotoAndStop(1);
						stage1.removeEventListener(e.type, fct);
					}
			}
			
			
				
				
				}
				
				function changeBack(e:Event, fct:Function, num:Number):void{
				
				if(num > 1){
					
					for(var x:Number = 0; x < num; x++){
						bgArray[x].alpha -= .1;
						trace(x + " : " + bgArray[x].alpha);
						if(bgArray[num-1].alpha <= 0){
						stage1.gotoAndStop(1);
						stage1.removeEventListener(e.type, fct);
						}
						trace('done');
						
					}
					trace('section');
				}
				else{
					bgArray[num].alpha += 0.1;
					if(bgArray[num].alpha >= 1){
						stage1.gotoAndStop(1);
						stage1.removeEventListener(e.type, fct);
					}
				}
			}
		}


	}
	
