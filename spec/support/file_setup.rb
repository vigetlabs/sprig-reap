module FileSetup
  # Create and remove seed folder around a spec
  def setup_seed_folder(path)
    FileUtils.mkdir_p(path)

    yield

    FileUtils.remove_dir(path)
  end
end
