#===============================================================================
#
#===============================================================================
class AnimationEditor::PlayControls < UIControls::ControlsContainer
  attr_reader :slowdown, :looping

  ROW_HEIGHT              = 28
  PLAY_BUTTON_X           = 241
  PLAY_BUTTON_Y           = 13
  PLAY_BUTTON_SIZE        = 22
  LOOP_BUTTON_X           = PLAY_BUTTON_X + PLAY_BUTTON_SIZE + 12
  LOOP_BUTTON_Y           = 16
  LOOP_BUTTON_SIZE        = 16
  # NOTE: Slowdown label is centered horizontally over the buttons.
  SLOWDOWN_LABEL_Y        = 0
  SLOWDOWN_BUTTON_X       = 1
  SLOWDOWN_BUTTON_Y       = ROW_HEIGHT - 1
  SLOWDOWN_BUTTON_WIDTH   = 32
  SLOWDOWN_BUTTON_SPACING = -3
  # NOTE: Duration label and value are centered horizontally on DURATION_TEXT_X.
  DURATION_TEXT_X         = 464
  DURATION_LABEL_Y        = SLOWDOWN_LABEL_Y
  DURATION_VALUE_Y        = ROW_HEIGHT
  SLOWDOWN_FACTORS        = [1, 2, 4, 6, 8]
  ICON_COLOR              = Color.black

  def initialize(x, y, width, height, viewport)
    super(x, y, width, height)
    @viewport.z = viewport.z + 10
    generate_button_bitmaps
    @duration = 0
    @slowdown = SLOWDOWN_FACTORS[0]
    @looping = false
  end

  #-----------------------------------------------------------------------------

  def add_play_controls
    # Play button
    play_button = UIControls::BitmapButton.new(PLAY_BUTTON_X, PLAY_BUTTON_Y, self.viewport, @play_button_bitmap)
    play_button.set_interactive_rects
    play_button.disable
    @controls.push([:play, play_button])
    # Stop button
    stop_button = UIControls::BitmapButton.new(PLAY_BUTTON_X, PLAY_BUTTON_Y, self.viewport, @stop_button_bitmap)
    stop_button.set_interactive_rects
    stop_button.visible = false
    @controls.push([:stop, stop_button])
    # Loop buttons
    loop_button = UIControls::BitmapButton.new(LOOP_BUTTON_X, LOOP_BUTTON_Y, self.viewport, @play_once_button_bitmap)
    loop_button.set_interactive_rects
    loop_button.visible = false if @looping
    @controls.push([:loop, loop_button])
    unloop_button = UIControls::BitmapButton.new(LOOP_BUTTON_X, LOOP_BUTTON_Y, self.viewport, @looping_button_bitmap)
    unloop_button.set_interactive_rects
    unloop_button.visible = false if !@looping
    @controls.push([:unloop, unloop_button])
    # Slowdown label
    duration_label = UIControls::Label.new(200, ROW_HEIGHT, self.viewport, _INTL("Slowdown factor"))
    duration_label.x = SLOWDOWN_BUTTON_X + (SLOWDOWN_FACTORS.length * (SLOWDOWN_BUTTON_WIDTH + SLOWDOWN_BUTTON_SPACING) / 2)
    duration_label.x -= (duration_label.text_width / 2) + 5
    duration_label.y = SLOWDOWN_LABEL_Y
    @controls.push([:slowdown_label, duration_label])
    # Slowdown factor buttons
    SLOWDOWN_FACTORS.each_with_index do |value, i|
      button = UIControls::Button.new(SLOWDOWN_BUTTON_WIDTH, ROW_HEIGHT, self.viewport, value.to_s)
      button.set_fixed_size
      button.x = SLOWDOWN_BUTTON_X + ((SLOWDOWN_BUTTON_WIDTH + SLOWDOWN_BUTTON_SPACING) * i)
      button.y = SLOWDOWN_BUTTON_Y
      button.set_interactive_rects
      button.set_highlighted if value == @slowdown
      @controls.push([("slowdown" + value.to_s).to_sym, button])
    end
    # Duration label
    duration_label = UIControls::Label.new(200, ROW_HEIGHT, self.viewport, _INTL("Duration"))
    duration_label.x = DURATION_TEXT_X - (duration_label.text_width / 2)
    duration_label.y = DURATION_LABEL_Y
    @controls.push([:duration_label, duration_label])
    # Duration value
    duration_value = UIControls::Label.new(200, ROW_HEIGHT, self.viewport, _INTL("{1}s", 0.0))
    duration_value.x = DURATION_TEXT_X - (duration_value.text_width / 2)
    duration_value.y = DURATION_VALUE_Y
    @controls.push([:duration_value, duration_value])
  end

  def generate_button_bitmaps
    @play_button_bitmap = Bitmap.new(PLAY_BUTTON_SIZE, PLAY_BUTTON_SIZE)
    (PLAY_BUTTON_SIZE - 2).times do |j|
      @play_button_bitmap.fill_rect(PLAY_BUTTON_SIZE / 4, j + 1, (j >= (PLAY_BUTTON_SIZE - 2) / 2) ? PLAY_BUTTON_SIZE - j : j + 3, 1, ICON_COLOR)
    end
    @stop_button_bitmap = Bitmap.new(PLAY_BUTTON_SIZE, PLAY_BUTTON_SIZE)
    @stop_button_bitmap.fill_rect(4, 4, PLAY_BUTTON_SIZE - 8, PLAY_BUTTON_SIZE - 8, ICON_COLOR)
    # Loop button
    @play_once_button_bitmap = Bitmap.new(LOOP_BUTTON_SIZE, LOOP_BUTTON_SIZE)
    @play_once_button_bitmap.fill_rect(1, 7, 11, 2, ICON_COLOR)
    @play_once_button_bitmap.fill_rect(8, 5, 2, 6, ICON_COLOR)
    @play_once_button_bitmap.fill_rect(10, 6, 1, 4, ICON_COLOR)
    @play_once_button_bitmap.fill_rect(13, 1, 2, 14, ICON_COLOR)
    @looping_button_bitmap = Bitmap.new(LOOP_BUTTON_SIZE, LOOP_BUTTON_SIZE)
    [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0,
     0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
     1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
     1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1,
     1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1,
     1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
     1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
     1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1,
     1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1,
     0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
     0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
     0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0].each_with_index do |val, i|
      next if val == 0
      @looping_button_bitmap.fill_rect(1 + (i % 14), 1 + (i / 14), 1, 1, ICON_COLOR)
    end
  end

  def dispose
    @play_button_bitmap.dispose
    @stop_button_bitmap.dispose
    @play_once_button_bitmap.dispose
    @looping_button_bitmap.dispose
    super
  end

  #-----------------------------------------------------------------------------

  def duration=(new_val)
    return if @duration == new_val
    @duration = new_val
    if @duration == 0
      get_control(:play).disable
    else
      get_control(:play).enable
    end
    ctrl = get_control(:duration_value)
    ctrl.text = _INTL("{1}s", @duration / 20.0)
    ctrl.x = DURATION_TEXT_X - (ctrl.text_width / 2)
    refresh
  end

  #-----------------------------------------------------------------------------

  def prepare_to_play_animation
    get_control(:play).visible = false
    get_control(:stop).visible = true
    @controls.each { |ctrl| ctrl[1].disable if ctrl[0] != :stop }
  end

  def end_playing_animation
    get_control(:stop).visible = false
    get_control(:play).visible = true
    @controls.each { |ctrl| ctrl[1].enable }
  end

  #-----------------------------------------------------------------------------

  def update
    super
    if @values
      @values.keys.each do |key|
        case key
        when :loop
          get_control(:loop).visible = false
          get_control(:unloop).visible = true
          @looping = true
          @values.delete(key)
        when :unloop
          get_control(:unloop).visible = false
          get_control(:loop).visible = true
          @looping = false
          @values.delete(key)
        else
          if key.to_s[/slowdown/]
            # A slowdown button was pressed; apply its effect now
            @slowdown = key.to_s.sub("slowdown", "").to_i
            @controls.each do |ctrl|
              next if !ctrl[0].to_s[/slowdown\d+/]
              if ctrl[0].to_s.sub("slowdown", "").to_i == @slowdown
                ctrl[1].set_highlighted
              else
                ctrl[1].set_not_highlighted
              end
            end
            @values.delete(key)
          end
        end
      end
      @values = nil if @values.empty?
    end
  end
end
