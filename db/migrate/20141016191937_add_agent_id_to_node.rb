class AddAgentIdToNode < ActiveRecord::Migration
  def change
    add_column    :nodes,                                         :agent_id,                    :uuid
    remove_column :nodes,                                         :proxy_url,                   :string,  default: '',      null: false
  end
end
