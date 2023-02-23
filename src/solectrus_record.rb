ENV['TZ'] = 'CET'

class SolectrusRecord
  def initialize(row)
    @row = row
  end

  attr_reader :row

  def to_h
    { name: 'SENEC', time:, fields: }
  end

  private

  def time
    parse_time(row, 'Uhrzeit')
  end

  def fields
    {
      inverter_power:,
      house_power:,
      bat_power_plus:,
      bat_power_minus:,
      bat_fuel_charge: nil,
      bat_charge_current:,
      bat_voltage:,
      grid_power_plus:,
      grid_power_minus:,
    }
  end

  def inverter_power
    @inverter_power ||= parse_kw(row, 'Stromerzeugung [kW]')
  end

  def house_power
    @house_power ||= parse_kw(row, 'Stromverbrauch [kW]')
  end

  def bat_power_plus
    # The CSV file format has changed over time, so two different column names are possible
    @bat_power_plus ||= parse_kw(row, 'Akkubeladung [kW]', 'Akku-Beladung [kW]')
  end

  def bat_power_minus
    # The CSV file format has changed over time, so two different column names are possible
    @bat_power_minus ||=
      parse_kw(row, 'Akkuentnahme [kW]', 'Akku-Entnahme [kW]')
  end

  def bat_charge_current
    @bat_charge_current ||= parse_a(row, 'Akku Stromstärke [A]')
  end

  def bat_voltage
    @bat_voltage ||= parse_v(row, 'Akku Spannung [V]')
  end

  def grid_power_plus
    @grid_power_plus ||= parse_kw(row, 'Netzbezug [kW]')
  end

  def grid_power_minus
    @grid_power_minus ||= parse_kw(row, 'Netzeinspeisung [kW]')
  end

  # KiloWatt
  def parse_kw(row, *columns)
    (cell(row, *columns).sub(',', '.').to_f * 1_000).round
  end

  # Ampere
  def parse_a(row, *columns)
    cell(row, *columns).sub(',', '.').to_f
  end

  # Volt
  def parse_v(row, *columns)
    cell(row, *columns).sub(',', '.').to_f
  end

  # Time
  def parse_time(row, string)
    Time.parse("#{row[string]} CET").to_i
  end

  def cell(row, *columns)
    # Find column by name (can have different names due to CSV format changes)
    column = columns.find { |col| row[col] }

    row[column] || throw("Column #{columns.join(' or ')} not found")
  end
end
