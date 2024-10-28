Rails.application.configure do
  config.good_job.enable_cron = true

  config.good_job.cron = {}

  if ENV["MARKETSTACK_API_KEY"].present?
    config.good_job.cron.merge!(
      import_securities: {
        cron: "0 1 * * *",
        class: "SecuritiesImportJob",
        description: "Import securities from the configured provider"
      }
    )
  end

  if ENV["UPGRADES_ENABLED"] == "true"
    config.good_job.cron.merge!(
      auto_upgrade: {
        cron: "*/30 * * * * *",
        class: "AutoUpgradeJob",
        description: "Check for new versions of the app and upgrade if necessary"
      }
    )
  end

  # Auth for jobs admin dashboard
  ActiveSupport.on_load(:good_job_application_controller) do
    before_action do
      raise ActionController::RoutingError.new("Not Found") unless current_user&.super_admin? || Rails.env.development?
    end

    def current_user
      session = Session.find_by(id: cookies.signed[:session_token])
      session&.user
    end
  end
end
