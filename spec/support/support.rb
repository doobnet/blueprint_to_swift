# frozen_string_literal: true

def data(path)
  full_path = File.join(BlueprintToSwift.root, 'spec/data', path)
  File.read(full_path)
end
