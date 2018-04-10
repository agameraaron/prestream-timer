#Prestream Timer
#MIT licensed, made by AGamerAaron of "VAR Team", 2017. No credit needed.
#If you spot any bugs, please report them!
#Is my code not optimal? Please tell me or submit improvements via github!
#

extends Node2D

var program_version = "0.3"
var version_name = "Usable"

var debug_mode = true #not used for anything yet

var timer_state = "stop"
var countdown_timer

var play_pressed = false
var stop_pressed = false
var announce_clicked = false
var details_clicked = false
var editor_post_focus = false
var focused_label = ""
var focused_editor = ""
var hour_max_limit_popup_active = false

var play_graphic
var pause_graphic
var white_text_color = Color(1.0,1.0,1.0,1.0)
var red_text_color = Color(1.0,0.1,0.1,1.0)
var green_text_color = Color(0.0,0.9,0.0,1.0)
var yellow_text_color = Color(0.9,0.8,0.0,1.0)

var seconds_timer_reset_workaround = false


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	countdown_timer = get_node("countdown timer")
#	countdown_timer = Timer.new()
#	countdown_timer.set_active(false)
#	countdown_timer.set_timer_process_mode(CONNECT_ONESHOT) #one shot mode, stops at zero
#	countdown_timer.set_one_shot(false)
#	add_child(countdown_timer)
	
	
	play_graphic = load("assets/sprites/play.png")
	pause_graphic = load("assets/sprites/pause.png")
	
	#due to a small bug, the timer cannot be set to exactly zero
	countdown_timer.emit_signal('timeout')
	#countdown_timer.set_wait_time(0.0001)
	
	#centering of the edit slots for a consistent look
	#get_node("countdown timer editor minutes").align("center")
	

func _physics_process(delta):
	
	#report the timer_state
	#print(timer_state)
	
	
	
		#If shift is not pressed, but enter is, then make it an official entry and drop the focus.
	if Input.is_key_pressed(KEY_SHIFT) == false and (Input.is_key_pressed(KEY_KP_ENTER) or Input.is_key_pressed(KEY_ENTER)) == true:
		#Seems it would release focus, yet I can go from one focus to another with no issues.
		# I feel like a bug could be produced here given there is no filter for it going through multiple loops.
		if get_node("details editor").has_focus():
			get_node("details editor").release_focus()
		elif get_node("countdown timer editor seconds").has_focus():
			get_node("countdown timer editor seconds").release_focus()
		elif get_node("countdown timer editor minutes").has_focus():
			get_node("countdown timer editor minutes").release_focus()
		elif get_node("countdown timer editor hours").has_focus():
			get_node("countdown timer editor hours").release_focus()
		elif get_node("announce editor").has_focus():
			get_node("announce editor").release_focus()
	
	
	
	if (focused_editor == ""):
		#don't show the label, but do show the editor while the editor has focus
		if get_node("announce editor").has_focus():
			#defining strings
			focused_label = "announce display"
			focused_editor = "announce editor"
			#if any editor is focused then it will hide the label
			get_node(focused_label).hide()
		elif get_node("countdown timer editor seconds").has_focus():
			focused_label = "countdown timer display seconds"
			focused_editor = "countdown timer editor seconds"
			get_node(focused_label).hide()
		elif get_node("countdown timer editor minutes").has_focus():
			focused_label = "countdown timer display minutes"
			focused_editor = "countdown timer editor minutes"
			get_node(focused_label).hide()
		elif get_node("countdown timer editor hours").has_focus():
			focused_label = "countdown timer display hours"
			focused_editor = "countdown timer editor hours"
			get_node(focused_label).hide()
		
		elif get_node("details editor").has_focus():
			focused_label = "details display"
			focused_editor = "details editor"
			get_node(focused_label).hide()
	
	
	
	
	
	#state machine for the timer
	
	#set play state from set state
	if timer_state == "set" and get_node("play button").is_pressed() and play_pressed == false:
		#workaround hack because if the time set is an invalid entry and manually...
		
		
		#countdown_timer.set_active(true)
		#print(str(countdown_timer.get_wait_time()))
		countdown_timer.start()
		
		play_pressed = true
		timer_state = "play"
		print("started timer")
		get_node("play button").set_button_icon(pause_graphic)
		
	#Countdown timer editor opens up if 'play' is pressed while stopped
	if timer_state == "stop" and get_node("play button").is_pressed() and play_pressed == false:
		
		#var new_countdown_time
		#show countdown timer editor if it's not in focus
		#If countdown timer editor is focused, release it so it can show the timer
		if get_node("countdown timer editor seconds").has_focus():
			get_node("countdown timer editor seconds").release_focus()
		#if countdown timer editor is reset, give it focus
		elif (get_node("countdown timer editor seconds").get_text() != "") and ((float(get_node("countdown timer editor seconds").get_text())) <= 0) :
			get_node("countdown timer editor seconds").grab_focus()
			get_node("countdown timer editor seconds").set_text("")
		
		play_pressed = true
	
	
	
	
	
	#set play state from pause state
	if timer_state == "pause" and get_node("play button").is_pressed() and play_pressed == false:
		 
		#show countdown timer editor
		#countdown_timer.set_active(true)
		countdown_timer.set_paused(false)
		
		play_pressed = true
		timer_state = "play"
		print("started timer")
		get_node("play button").set_button_icon(pause_graphic)
		
	#set pause state from play state
	if timer_state == "play" and get_node("play button").is_pressed() and play_pressed == false:
		countdown_timer.set_wait_time(countdown_timer.get_time_left())
		#countdown_timer.set_active(false)
		countdown_timer.set_paused(true)
		
		play_pressed = true
		timer_state = "pause"
		print("paused timer")
		get_node("play button").set_button_icon(play_graphic)
		
	#when the play/pause button is released
	if !(get_node("play button").is_pressed()):
		play_pressed = false
	
	
	#if the stop button is pressed, not dependent on timer state
	if get_node("stop button").is_pressed() and stop_pressed == false:
		countdown_timer.stop()
		#countdown_timer.set_wait_time(0)
		#countdown_timer.set_wait_time(0.0001)
		countdown_timer.emit_signal('timeout')
		#seconds_timer_reset_workaround = true
		
		stop_pressed = true
		timer_state = "stop"
		print("stopped timer")
		get_node("play button").set_button_icon(play_graphic)
		
		#reset all displayed time
		get_node("countdown timer display seconds").set_text("00")
		get_node("countdown timer display minutes").set_text("00")
		get_node("countdown timer display hours").set_text("0")
		
	
	#when the stop button is released
	if !(get_node("stop button").is_pressed()):
		stop_pressed = false
	
	
	
	#unattended states
	if timer_state == "play":
		
		
		#a hack because of the timer not being able to be set to zero
		#actually, just going to make it equal a very small time instead until this is fixed upstream
#		if seconds_timer_reset_workaround == true:
#			countdown_timer.stop()
#			timer_state = "stop"
#			seconds_timer_reset_workaround = false
		
		#update the countdown timer display
		var timer_time_left = countdown_timer.get_time_left()
		var timer_time_left_string = "%0.3f" % timer_time_left  #Wait... what's this do again?? It's changing it to a string and...
		
		#timer_time_left.resize(5)
		#print("timer time left: "+str(timer_time_left))
		get_node("countdown timer display seconds").set_text(str(timer_time_left_string))
		#I don't know what I'm doing here with these colors
		#get_node("countdown timer display seconds").get_color("orange",Color)
		
		if int(get_node("countdown timer display minutes").get_text()) == 0 and int(get_node("countdown timer display hours").get_text()) == 0:
			if timer_time_left < 0.001:
				countdown_timer.stop()
				#countdown_timer.set_wait_time(0.0001)
				countdown_timer.emit_signal('timeout')
				#countdown_timer.set_wait_time(0)
				#seconds_timer_reset_workaround = true
				print("timer timed out")
				timer_state = "stop"
				get_node("play button").set_button_icon(play_graphic)
				
				#reset seconds display
				get_node("countdown timer display seconds").set_text("00")
			
		
	
	#print(focused_editor+"     "+str(get_node("countdown timer editor seconds").has_focus()))
	
	
	#when focus is lost on the seconds editor, set the timer
	if focused_editor == "countdown timer editor seconds" and !(get_node("countdown timer editor seconds").has_focus()):
		#print("seconds entry: "+get_node("countdown timer editor seconds").get_text())
		if int(get_node(focused_editor).get_text()):
			
			timer_state = "set"
			
			#During user input, convert seconds to hours: for every 3600 seconds, an hour is tallied
			if int(get_node(focused_editor).get_text()) > 3600:
				var new_hours = int(get_node(focused_editor).get_text()) / 3600
				while new_hours > 0:
					get_node("countdown timer display hours").set_text(str(1 + int(get_node("countdown timer display hours").get_text())))
					new_hours = new_hours - 1
					print("hour added from seconds")
					get_node("countdown timer editor seconds").set_text(str(int(get_node("countdown timer editor seconds").get_text()) - 3600 ))
				
			#Convert seconds to minutes: for every 60 seconds, a minute is tallied
			if int(get_node(focused_editor).get_text()) > 60:
				
				var new_minutes = int(get_node(focused_editor).get_text()) / 60
				while new_minutes > 0:
					get_node("countdown timer display minutes").set_text(str(1 + int(get_node("countdown timer display minutes").get_text())))
					new_minutes = new_minutes - 1
					print("minute added from seconds")
					get_node("countdown timer editor seconds").set_text(str(int(get_node("countdown timer editor seconds").get_text()) - 60 ))
			
			
			
			var remainder_for_seconds = int(get_node("countdown timer display seconds").get_text()) % 60
			print("remainder for seconds: "+str(remainder_for_seconds))
			
			countdown_timer.set_wait_time(float(get_node(focused_editor).get_text()))
			
			#print("valid second time entry")
		else: #either zero or a non-number
			print("Not a valid entry!")
			#reset everything seconds related to zero here
			timer_state = "stop"
			#countdown_timer.set_wait_time(0)
			#print("Bug!: "+str(countdown_timer.get_wait_time())) #Why is it refusing to set a zero?? Gotta be an upstream bug...
			#countdown_timer.set_wait_time(0.0001)
			countdown_timer.emit_signal('timeout')
			seconds_timer_reset_workaround = true
			
			get_node("countdown timer editor seconds").set_text("00")
			get_node("countdown timer display seconds").set_text("00")
			
			
	#when focus is lost on the hours editor, set the timer
	if focused_editor == "countdown timer editor minutes" and !(get_node("countdown timer editor minutes").has_focus()):
		if int(get_node(focused_editor).get_text()):
			#countdown_timer.set_wait_time(float(get_node(focused_editor).get_text()))
			timer_state = "set"
			#print("valid minute time entry")
			
			#convert minutes to hours: for every 60 minutes, an hour is tallied
			if int(get_node("countdown timer display minutes").get_text()) > 60:
				
				var new_minutes = int(get_node("countdown timer display minutes").get_text()) / 60
				while new_minutes > 0:
					get_node("countdown timer display hours").set_text(str(1 + int(get_node("countdown timer display hours").get_text())))
					new_minutes = new_minutes - 1
				
		else:
			print("Not a valid entry!")
	
	#when focus is lost on the hours editor, set the timer
	if focused_editor == "countdown timer editor hours" and !(get_node("countdown timer editor hours").has_focus()):
		if int(get_node(focused_editor).get_text()):
			if int(get_node(focused_editor).get_text()) <= 200:
			
				#countdown_timer.set_wait_time(float(get_node(focused_editor).get_text()))
				timer_state = "set"
				#print("valid hour time entry")
			else:
				hour_max_limit_popup_active = true
				get_node("popup curtain").show()
				get_node("popup curtain/hour max limit error message box").show()
				#print("Hours exceeding 99! Are you really going to leave your audience hanging that long...?")
		else:
			print("Not a valid entry!")
	
	
	
	#This all appears obsolesced... probably fixed in Godot Engine 3.0
	
	#If focus is lost, then update the label! 
	#Should only trigger one frame because the very condition for it is being changed
	if focused_editor != "" and !(get_node(focused_editor).has_focus()):
		var new_label_text = get_node(focused_editor).get_text()
		get_node(focused_label).set_text(new_label_text)
		get_node(focused_label).show()
		
		if focused_editor == "countdown timer editor seconds":
			if int(get_node("countdown timer editor seconds").get_text()):
				countdown_timer.set_wait_time(float(get_node(focused_editor).get_text()))
				
				timer_state = "set"  #Bad idea??
				#print("timer is set, seconds: "+(get_node(focused_editor).get_text()))
		
		get_node(focused_editor).set_text("")
		
		#print("result: "+get_node(focused_label).get_text())
		focused_label = ""
		focused_editor = ""
		
	
	timer_text_color()
	

func timer_text_color():
	if timer_state == "stop":
		get_node("countdown timer display seconds").modulate = (red_text_color)#set_font_color(red_text_color)
		get_node("countdown timer display minutes").modulate = (red_text_color)
		get_node("countdown timer display hours").modulate = (red_text_color)
	elif timer_state == "pause":
		get_node("countdown timer display seconds").modulate = (yellow_text_color)
		get_node("countdown timer display minutes").modulate = (yellow_text_color)
		get_node("countdown timer display hours").modulate = (yellow_text_color)
	elif timer_state == "play":
		get_node("countdown timer display seconds").modulate = (green_text_color)
		get_node("countdown timer display minutes").modulate = (green_text_color)
		get_node("countdown timer display hours").modulate = (green_text_color)
	elif timer_state == "set":
		get_node("countdown timer display seconds").modulate = (white_text_color)
		get_node("countdown timer display minutes").modulate = (white_text_color)
		get_node("countdown timer display hours").modulate = (white_text_color)


func _on_countdown_timer_timeout():
	#minute deduction
	if int(get_node("countdown timer display minutes").get_text()) > 0:
		get_node("countdown timer display minutes").set_text( str( int(get_node("countdown timer display minutes").get_text()) - 1 ) )
		get_node("countdown timer").set_wait_time(60)
		get_node("countdown timer").start()
	#hour deduction
	if int(get_node("countdown timer display minutes").get_text()) == 0 and int(get_node("countdown timer display hours").get_text()) > 0:
		get_node("countdown timer display hours").set_text( str( int(get_node("countdown timer display hours").get_text()) - 1 ) )
		get_node("countdown timer display minutes").set_text( str( 59 ) )
		get_node("countdown timer").set_wait_time(60)
		get_node("countdown timer").start()
		
	
	



func _on_hour_max_limit_error_message_box_button_pressed():
	hour_max_limit_popup_active = false
	get_node("popup curtain/hour max limit error message box").hide()
	get_node("popup curtain").hide()

#End of program




