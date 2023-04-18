class Application
  hash_branch('') do |r|

    # GET /
    r.get do
      view :root
    end

  end
end
