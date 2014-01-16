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
	

	public class days extends MovieClip {

		var myXML:XML;
		var current_weather:MovieClip;
		var wid:int;
		var dayArray:Array = [];
		var master:MovieClip;
		var iconArray:Array = [];
		var weekDays:Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		var date:Date;
		var today:Number;
		var localObject:SharedObject = SharedObject.getLocal("localObjectID");
		var dateFormat:DateTimeFormatter = new DateTimeFormatter("en-US");
		
		public function days() {
			
			current_weather = new stage_mc;
			date = new Date();
			dateFormat.setDateTimePattern("MM-dd");
			current_weather.enter_btn.addEventListener(MouseEvent.CLICK, changeWeather);
			current_weather.local_btn.addEventListener(MouseEvent.CLICK, storeData);
			for(var i:Number = 1; i<7; i++){
				var temp:String = "today_btn" + i;
				current_weather[temp].addEventListener(MouseEvent.CLICK, todayEvent);
			}
			today = date.day;
			current_weather.x=0;
			current_weather.y=0;
			addChild(current_weather);
			dayArray[0] = current_weather.day1;
			dayArray[1] = current_weather.day2;
			dayArray[2] = current_weather.day3;
			dayArray[3] = current_weather.day4;
			dayArray[4] = current_weather.day5;
			dayArray[5] = current_weather.day6;
			dayArray[6] = current_weather.day7;
			GetXMLData();
			
		}

		public function storeData(e:Event):void{
			
			var text:String = current_weather.stored_txt.text;
			localObject.data.city = current_weather.stored_txt.text;
			var inject:String = strReplace(text, " ", "+");
			localObject.data.cityURL = "http://api.openweathermap.org/data/2.5/forecast/daily?q="+inject+"&mode=xml&units=imperial&cnt=7&nocache="+ new Date().getTime();
			localObject.flush();
			}
		
		public function changeWeather(e:Event):void{
			
		var text:String = current_weather.input_txt.text;
		var inject:String = strReplace(text, " ", "+");
		var file:URLRequest = new URLRequest("http://api.openweathermap.org/data/2.5/forecast/daily?q="+inject+"&mode=xml&units=imperial&cnt=7&nocache="+ new Date().getTime());
		var myLoader:URLLoader = new URLLoader();
		myLoader.load(file);
		myLoader.addEventListener(Event.COMPLETE, processXML);
		}
		
		function strReplace(str:String, search:String, replace:String):String{
			return str.split(search).join(replace);
		}
		
		public function GetXMLData():void{
			var url:String;
			trace(localObject.data.cityURL);
			if(localObject.data.cityURL != null){
				url = localObject.data.cityURL;
				current_weather.City_txt.text = localObject.data.city +"";
			}
			else{
				url = "http://api.openweathermap.org/data/2.5/forecast/daily?q=Salt+Lake+City,UT&mode=xml&units=imperial&cnt=7&nocache="+ new Date().getTime();
				current_weather.City_text.text = "Not set yet";
			}
		
		var file:URLRequest = new URLRequest(url);
		var myLoader:URLLoader = new URLLoader();
		myLoader.load(file);
		myLoader.addEventListener(Event.COMPLETE, processXML);

		}
		
		function todayEvent(e:Event):void{
			var num:Number = Number(e.target.name.substr(9));
			if(num >= 5)num++;
			swapWeather(5, num);
		}
		
		function swapWeather(oldDay:Number, newDay:Number):void{
			var tempDay:MovieClip = new weather_mc;
			tempDay.Day_txt.text = current_weather["day5"].Day_txt.text;
			tempDay.Min_txt.text = current_weather["day5"].Min_txt.text;
			tempDay.Max_txt.text = current_weather["day5"].Max_txt.text;
			tempDay.Weather_txt.text = current_weather["day5"].Weather_txt.text;
			tempDay.Date_txt.text = current_weather["day5"].Date_txt.text;
			tempDay.weatherCode = current_weather["day5"].weatherCode;
			
			current_weather["day5"].Day_txt.text = current_weather["day" + newDay].Day_txt.text;
			current_weather["day5"].Min_txt.text = current_weather["day" + newDay].Min_txt.text;
			current_weather["day5"].Max_txt.text = current_weather["day" + newDay].Max_txt.text;
			current_weather["day5"].Weather_txt.text = current_weather["day" + newDay].Weather_txt.text;
			current_weather["day5"].Date_txt.text = current_weather["day" + newDay].Date_txt.text;
			current_weather["day5"].weatherCode = current_weather["day" + newDay].weatherCode;
			
			current_weather["day5"].gotoAndStop(current_weather["day"+ newDay].weatherCode);
			current_weather["day" +newDay].Day_txt.text = tempDay.Day_txt.text;
			current_weather["day" +newDay].Min_txt.text = tempDay.Min_txt.text;
			current_weather["day" +newDay].Max_txt.text = tempDay.Max_txt.text;
			current_weather["day" +newDay].Weather_txt.text = tempDay.Weather_txt.text;
			current_weather["day" +newDay].Date_txt.text = tempDay.Date_txt.text;
			current_weather["day" +newDay].weatherCode = tempDay.weatherCode;
			current_weather["day" +newDay].gotoAndStop(tempDay.weatherCode);
			
			
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
			
			for(var i:Number = 0; i < dayArray.length+1; i++){
				var theDay = "day" + (i+1);
				var num:Number = parseWeather(i);
				current_weather[theDay].gotoAndStop(num);
			}
		
			todaysDay();
		}
		
		function todaysDay():void{
			var test:String = dateFormat.format(new Date());
			var index:Number = 0;
			var tempDay:MovieClip;
			
			for(var i:Number = 0; i < dayArray.length; i++){
				trace(dayArray[i].Date_txt.text + " == " + test);
				if(dayArray[i].Date_txt.text == test){
					index = i;
					break;
				}
			
			}
			index = index +1;
			trace(index + " CHECK THIS");
			
			swapWeather(5, (index));
			
			//ArrangeDays();
			/*var wCode:Number = parseWeather((index + 1));
			current_weather["day5"].gotoAndStop(1);
			current_weather["day" +(index+1)].gotoAndStop(3);
			*/
		}
		
		function ArrangeDays():void{
			var hasChanged:Boolean = true;
			var date1:Number;
			var date2:Number;
			while(hasChanged){
				hasChanged = false;
			for(var i:Number = 0; i < dayArray.length-2; i++){
				date1 = Number(dayArray[i].Date_txt.text.substr(3));
				date2 = Number(dayArray[i + 1].Date_txt.text.substr(3));
				
				if(date1 > date2){
					var temp:MovieClip = dayArray[i];
					dayArray[i] = dayArray[i + 1];
					dayArray[i + 1] = temp;
					hasChanged = true;
				}
			}
		}
		for each(var x:MovieClip in dayArray){
			trace(x.Date_txt.text.substr(3));
		}

		}
		
		function parseWeather(y:Number):Number{
			var dateText:String;
			var weather:String;
			var min:String;
			var max:String;
			var wCode:Number;
		
			if(myXML != null){
				
					if(myXML.forecast.time[y].precipitation.@type.length() > 0){
						
						var type2:String = myXML.forecast.time[y].precipitation.@type;
						switch(type2){
						case "snow":
							wCode = 5;
							weather = "Snow and\n" + myXML.forecast.time[y].clouds.@value;
							break;
						case "rain":
							wCode = 2;
							weather = "Rain and\n" + myXML.forecast.time[y].clouds.@value;
							break;
						
						}
					}
					else{
					weather = myXML.forecast.time[y].clouds.@value;
						trace(myXML.forecast.time[y].temperature.@max);
					var forecastCode:Number =  Number(myXML.forecast.time[y].symbol.@number);
					//trace(maxNum < 80 && maxNum > 20 );
							
							if(weather.indexOf("clear") >= 0){
								wCode = 1;
							}
							else if(weather.indexOf("scattered") >= 0 || weather.indexOf("broken") >= 0){
								wCode = 6;
							}
							else if(weather.indexOf("cloud") >= 0){
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
						
					} 
					if(today == 7)today = 0;
					dayArray[y].Day_txt.text = weekDays[today];
					min = myXML.forecast.time[y].temperature.@min;
					max = myXML.forecast.time[y].temperature.@max;
					dayArray[y].Min_txt.text = min;
					dayArray[y].Max_txt.text = max;
					dayArray[y].weatherCode = wCode;
					
					dayArray[y].Weather_txt.text = weather;
					dayArray[y].Date_txt.text = dateFormat.format(date);
					today++;
					date.setDate(date.getDate() + 1);
					
					 
			}
			
			if(weather.indexOf("overcast") >= 0)wCode = 3;
		return wCode;
	}
			
		function processXML(e:Event):void {
		
		myXML = new XML(e.target.data);
			showDay();
		}
			
		} 
		
	/*public function FillArray():void{
			master = new stage_mc;
			master.x=0;
			master.y=0;
			
			addChild(master);
	
			for(var i:Number = 0; i<7; i++){
				if(i == 0){
					dayArray[i] = new weather_mc;
					dayArray[i].x = -217.5;
					dayArray[i].y = -171.30;
					
				}
				else{
					
					dayArray[i] = new weather_mc;
					dayArray[i].x 
				}
				
				addChild(dayArray[i]);
			}
		} */
		

	}
