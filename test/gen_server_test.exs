defmodule ExFussballDeScraper.GenServerTest do
  use ExUnit.Case, async: true
  doctest ExFussballDeScraper.GenServer

  setup do
    gen_server = start_supervised!(ExFussballDeScraper.GenServer)
    %{gen_server: gen_server}
  end

  # test "spawns buckets", %{registry: registry} do
  #   assert KV.Registry.lookup(registry, "shopping") == :error

  #   KV.Registry.create(registry, "shopping")
  #   assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

  #   KV.Bucket.put(bucket, "milk", 1)
  #   assert KV.Bucket.get(bucket, "milk") == 1
  # end
end
