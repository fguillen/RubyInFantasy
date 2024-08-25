require "fantasy" # Yeah!
require "tween"

#
# This game has been implemented without the use of any custom class
# in order to show the flexibility of the fantasy API to implement
# games with a simple and flat architecture
#

SCREEN_WIDTH = 768
SCREEN_HEIGHT = 768

on_game do
  Global.references.fruits = 0

  background = Background.new(image_name: "background")
  background.scale = 2

  animation_idle = Animation.new(secuence: "chicken_idle_secuence", columns: 13, speed: 20)
  animation_moving = Animation.new(secuence: "chicken_moving_secuence", columns: 14, speed: 20)
  chicken = Actor.new(animation_idle)
  chicken.position = Coordinates.new(300, 580)
  chicken.scale = 4
  chicken.speed = 300
  chicken.move_with_cursors(left: true, right: true)
  chicken.solid = true
  chicken.collision_with = ["fruit"]
  chicken.on_after_move do
    if chicken.direction.x > 0
      chicken.flip = "horizontal"
    elsif chicken.direction.x < 0
      chicken.flip = "none"
    end
  end

  chicken.on_collision do |other|
    if(other.name == "fruit")
      other.destroy
      get_the_fruit
      chicken.state(:eating)
      background.scale = 2.2
      Clock.new { background.scale = 2 }.run_on(seconds: 0.2)
    end
  end

  chicken.on_state(:eating) do
    chicken_actual_scale = chicken.scale
    chicken_actual_speed = chicken.speed

    chicken.speed = 0

    tween =
      Tween.new(
        chicken.scale,
        chicken.scale + 2,
        Tween::Elastic::Out,
        1
      )

    Clock.new do
      start_at = Global.seconds_in_scene
      delta = 0

      while(delta < 1) do
        delta = Global.seconds_in_scene - start_at
        tween.update(delta)
        chicken.scale = tween.value
        puts ">>>> #{chicken.scale}"
        # sleep(0.01)
      end

      chicken.scale = chicken_actual_scale
      chicken.speed = chicken_actual_speed
    end.run_now
  end

  chicken.on_state(:moving) do
    chicken.sprite = animation_moving
  end

  chicken.on_state(:idle) do
    chicken.sprite = animation_idle
  end

  Clock.new { spawn_fruit }.repeat(seconds: 1)

  on_loop do
    background.position.y +=  1

    if chicken.direction != Coordinates.zero
      chicken.state(:moving)
    else
      chicken.state(:idle)
    end
  end
end

def spawn_fruit
  animation = Animation.new(secuence: "apple_secuence", columns: 7, speed: 15, frame: rand(0..6))
  fruit = Actor.new(animation)
  fruit.name = "fruit"
  fruit.position = Coordinates.new(rand(0..SCREEN_WIDTH), 0)
  fruit.scale = 4
  fruit.speed = 300
  fruit.direction = Coordinates.down

  fruit
end

def get_the_fruit
  Global.references.fruits += 1
  puts ">>>> #{Global.references.fruits}"
end

start!
