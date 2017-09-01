#Prestream Timer
#MIT licensed, made by AGamerAaron of "VAR Team", 2017. No credit needed.
#If you spot any bugs, please report them!
#Is my code not optimal? Please tell me or submit improvements via github!
#

extends Node2D

var program_version = "0.2"
var version_name = "Functional"

var debug_mode = true #not used for anything yet

var timer_state = "stop"
var countdown_timer
var timer_reset = false

var play_pressed = false
var stop_pressed = false
var announce_clicked = false
var details_clicked = false
var editor_post_focus = false
var focused_label = ""
var focused_editor = ""

var play_graphic
var pause_graphic

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
	
	set_fixed_process(true)
	

func _fixed_process(delta):
	
	
		#If shift is not pressed, but enter is, then make it an official entry and drop the focus.
	if Input.is_key_pressed(KEY_SHIFT) == false and (Input.is_key_pressed(KEY_RETURN) or Input.is_key_pressed(KEY_ENTER)) == true:
		if get_node("details editor").has_focus():
			get_node("details editor").release_focus()
		elif get_node("countdown timer editor seconds").has_focus():
			get_node("countdown timer editor seconds").release_focus()
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
		
		countdown_timer.set_active(true)
		countdown_timer.start()
		
		play_pressed = true
		timer_state = "play"
		print("started timer")
		get_node("play button").set_button_icon(pause_graphic)
		
	#Countdown timer editor opens up if 'play' is pressed while stopped
	if timer_state == "stop" and get_node("play button").is_pressed() and play_pressed == false:
		
		var new_countdown_time
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
		countdown_timer.set_active(true)
		
		play_pressed = true
		timer_state = "play"
		print("started timer")
		get_node("play button").set_button_icon(pause_graphic)
		
	#set pause state from play state
	if timer_state == "play" and get_node("play button").is_pressed() and play_pressed == false:
		countdown_timer.set_wait_time(countdown_timer.get_time_left())
		countdown_timer.set_active(false)
		
		
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
		countdown_timer.set_wait_time(0)
		
		stop_pressed = true
		timer_state = "stop"
		print("stopped timer")
		get_node("play button").set_button_icon(play_graphic)
	
	#when the stop button is released
	if !(get_node("stop button").is_pressed()):
		stop_pressed = false
	
	
	
	#unattended states
	if timer_state == "play":
		#update the countdown timer display
		var timer_time_left = countdown_timer.get_time_left()
		timer_time_left = "%0.3f" % timer_time_left
		#timer_time_left.resize(5)
		print("timer time left: "+str(timer_time_left))
		get_node("countdown timer display seconds").set_text(str(timer_time_left))
		#I don't know what I'm doing here with these colors
		#get_node("countdown timer display seconds").get_color("orange",Color)
		
		
		
	
	#print(focused_editor+"     "+str(get_node("countdown timer editor seconds").has_focus()))
	
	
	#when focus is lost on the seconds editor, set the timer
	if focused_editor == "countdown timer editor seconds" and !(get_node("countdown timer editor seconds").has_focus()):
		
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
			
			print("valid time entry")
		else:
			print("Not a valid entry!")
			
	#when focus is lost on the hours editor, set the timer
	if focused_editor == "countdown timer editor minutes" and !(get_node("countdown timer editor minutes").has_focus()):
		if int(get_node(focused_editor).get_text()):
			countdown_timer.set_wait_time(float(get_node(focused_editor).get_text()))
			timer_state = "set"
			print("valid time entry")
			
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
			if int(get_node(focused_editor).get_text()) < 9:
			
				countdown_timer.set_wait_time(float(get_node(focused_editor).get_text()))
				timer_state = "set"
				print("valid time entry")
			else:
				print("Hours exceeding 9! Are you really going to leave your audience hanging that long...?")
		else:
			print("Not a valid entry!")
	
	
	
	
	
	#If focus is lost, then update the label! 
	#Should only trigger one frame because the very condition for it is being changed
	if focused_editor != "" and !(get_node(focused_editor).has_focus()):
		var new_label_text = get_node(focused_editor).get_text()
		get_node(focused_label).set_text(new_label_text)
		get_node(focused_label).show()
		
		if focused_editor == "countdown timer editor seconds":
			countdown_timer.set_wait_time(float(get_node(focused_editor).get_text()))
			
			
			timer_state = "set"
			print("timer is set")
		
		get_node(focused_editor).set_text("")
		
		print("result: "+get_node(focused_label).get_text())
		focused_label = ""
		focused_editor = ""
		
	


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
		
	
	



#End of program