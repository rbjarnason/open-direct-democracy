namespace :utils do
  desc "Archive cases"
  task(:archive_cases => :environment) do
      if ENV['current_thing_id']
        logg = "#{ENV['current_thing_id']}. lög"
        puts "Archiving all cases except for thing: #{logg}"
        Case.find(:all).each do |c|
          puts c.info_3
          unless c.info_3.index(logg)
            puts "ARCHIVING"
            c.archived = true
            c.save
          end
        end
      end
  end

  desc "Backup"
  task(:backup => :environment) do
      filename = "beint.lydraedi.is_#{Time.new.strftime("%d%m%y_%H%M%S")}.sql"
      system("mysqldump -u robert --force --password=zaijei7E odd_master > /home/robert/#{filename}")
      system("gzip /home/robert/#{filename}")
      system("scp /home/robert/#{filename}.gz robert@where.is:backups/#{filename}.gz")
      system("rm /home/robert/#{filename}.gz")
  end

  desc "Delete Fully Processed Masters"
  task(:delete_fullly_processed_masters => :environment) do
      masters = CaseSpeechMasterVideo.find(:all)
      masters.each do |master_video|
        puts "master_video id: #{master_video.id} all_done: #{master_video.case_speech_videos.all_done?} has_any_in_processing: #{master_video.case_speech_videos.any_in_processing?}"
        if master_video.case_speech_videos.all_done? and not master_video.case_speech_videos.any_in_processing?
          master_video_flv_filename = "#{RAILS_ROOT}/private/"+ENV['RAILS_ENV']+"/case_speech_master_videos/#{master_video.id}/master.flv"
          if File.exist?(master_video_flv_filename)
            rm_string = "rm #{master_video_flv_filename}"
            puts rm_string
            system(rm_string)
          end
        end
      end
  end

  desc "Exlpore broken videos"
  task(:explore_broken_videos => :environment) do
      masters = CaseSpeechMasterVideo.find(:all)
      masters.each do |master_video|
        unless master_video.case_speech_videos.all_done? and not master_video.case_speech_videos.any_in_processing?
          master_video_flv_filename = "#{RAILS_ROOT}/private/"+ENV['RAILS_ENV']+"/case_speech_master_videos/#{master_video.id}/master.flv"
          if File.exist?(master_video_flv_filename)
            puts "master_video id: #{master_video.id} all_done: #{master_video.case_speech_videos.all_done?} has_any_in_processing: #{master_video.case_speech_videos.any_in_processing?}"
            master_video.case_speech_videos.each do |video|
              puts "video id #{video.id} published #{video.published} #{video.title} in_processing #{video.in_processing} duration: #{video.duration_s} in: #{video.inpoint_s}"            
            end
            puts " "
          end
        end
      end
  end
end
