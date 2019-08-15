require_relative '../../spec_helper'

describe "Process.setpgid" do
  platform_is_not :windows do
    # Must use fork as setpgid(2) gives EACCESS after execve()
    it "sets the process group id of the specified process" do
      rd, wr = IO.pipe

      pid = Process.fork do
        wr.close
        rd.read
        rd.close
        Process.exit!
      end

      rd.close

      begin
        Process.getpgid(pid).should == Process.getpgrp
        Process.setpgid(mock_int(pid), mock_int(pid)).should == 0
        Process.getpgid(pid).should == pid
      ensure
        wr.write ' '
        wr.close
        Process.wait pid
      end
    end
  end
end
