require_relative '../../lib/tools/alg.rb'
threads = []

threads << Thread.new { Parse_akc.new }
threads << Thread.new { Parse_auto_sto.new }
threads << Thread.new { Parse_autoliga.new }

threads.each { |thr| thr.join }

par1, par2, par3 = threads[0].value, threads[1].value, threads[2].value

comp = Comprator.new(par1, par3, par2)
comp.compare_services

class ComparatorController < ApplicationController

  before_action :authenticate_user!

  def index
    @email = current_user.email

  end

  def download

    send_file '/home/kirill/hello/public/comparator_tar (1)/Kirpich/lib/tools/excel.xls', :disposition => 'attachment'
  end
end
