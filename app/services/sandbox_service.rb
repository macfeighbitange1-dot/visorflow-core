require 'net/http'
require 'json'

class SandboxService
  BASE_URL = "http://127.0.0.1:4000"

  # 1. THE ACTION: Execute code with Auto-Healing
  def self.execute(agent_name, command)
    response = post_to_orchestrator("/exec", { agentName: agent_name, command: command })

    if response["error"] == "Agent sandbox not found"
      puts "⚠️  [RECONCILIATION] Agent #{agent_name} missing. Re-launching..."
      launch(agent_name, "alpine") 
      response = post_to_orchestrator("/exec", { agentName: agent_name, command: command })
    end

    ::Workload.find_by(agent_id: agent_name)&.update(last_health_check: Time.current)
    response
  end

  # 2. THE DEPLOYMENT: Launch a new gVisor Sandbox
  def self.launch(agent_name, code_image)
    result = post_to_orchestrator("/deploy", { imageName: code_image, agentName: agent_name })

    if result["status"] == "success"
      workload = ::Workload.find_or_initialize_by(agent_id: agent_name)
      workload.update!(
        internal_ip: result["ip"],
        status: "running",
        last_health_check: Time.current
      )
    end
    result
  end

  # 3. THE MONITOR: Global Health Sync (Phase 5)
  def self.sync_all
    response = get_from_orchestrator("/health")
    return { error: "Health endpoint unreachable: #{response['error']}" } if response["error"]

    active_names = response["manifest"].map { |m| m["name"].gsub(/^\//, "") }

    ::Workload.where(status: "running").each do |workload|
      unless active_names.any? { |docker_name| docker_name.include?(workload.agent_id) }
        workload.update(status: "terminated")
        puts "📉 [SYNC] Agent #{workload.agent_id} marked as terminated."
      end
    end

    { status: "success", active_agents: response["active_agents"] }
  end

  private

  def self.post_to_orchestrator(path, payload)
    uri = URI.parse("#{BASE_URL}#{path}")
    req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    req.body = payload.to_json

    begin
      res = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
      JSON.parse(res.body)
    rescue StandardError => e
      { "error" => "Orchestrator Connection Failure: #{e.message}" }
    end
  end

  def self.get_from_orchestrator(path)
    uri = URI.parse("#{BASE_URL}#{path}")
    begin
      res = Net::HTTP.get_response(uri)
      JSON.parse(res.body)
    rescue StandardError => e
      { "error" => "Connection Failure: #{e.message}" }
    end
  end
end
