class DS
  def initialize
    %w[mouse cpu keyboard display].each do |equipment|
      %w[info price].each do |name|
        self.class.define_component(equipment, name)
      end
    end
  end

  def self.define_component(equipment, name)
    define_method "get_#{equipment}_#{name}" do |arg|
      data[arg]["#{equipment}".to_sym]["#{name}".to_sym]
    end
  end

  private

  def data
    {
      4 => {
        mouse: { price: 720, info: 'Magic Mouse' },
        keyboard: { price: 1200, info: 'KGB' },
        cpu: { price: 2000, info: '酷睿i7' }
      }
    }
  end
end
