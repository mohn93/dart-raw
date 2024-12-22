import 'dart:typed_data';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:raw/raw.dart';

void main() {
  const minLength = 128;

  // writeUtf8(...)
  new WriteUtf8Benchmark().report();

  // writeUint8List(...): Aligned copy, uint8 chunks
  new WriteUint8ListBenchmark(0, 0, minLength - 1).report();
  // writeUint8List(...): Aligned copy, uint32 chunks + uint8 chunks
  new WriteUint8ListBenchmark(0, 0, minLength + 1).report();

  // writeUint8List(...): Non-aligned copy, uint8 chunks
  new WriteUint8ListBenchmark(63, 63, minLength - 1).report();
  // writeUint8List(...): Non-aligned copy, uint32 chunks + uint8 chunks
  new WriteUint8ListBenchmark(63, 63, minLength + 1).report();
}

class WriteUtf8Benchmark extends BenchmarkBase {
  static const times = 100;
  static const value =
      "013456789013456789013456789013456789013456789013456789013456789013456789013456789013456789";
  RawWriter _destination;

  WriteUtf8Benchmark()
      : super(
          "writeUtf8(...): $times times",
        );

  @override
  void setup() {
    _destination = new RawWriter.withCapacity(times * value.length);
    super.setup();
  }

  @override
  void run() {
    // Set initial index
    _destination.length = 0;

    for (var i = 0; i < times; i++) {
      // Copy from source to destination
      _destination.writeUtf8(value);
    }
  }
}

class WriteUint8ListBenchmark extends BenchmarkBase {
  static const times = 100;
  final int destinationIndex;
  final int sourceIndex;
  final int length;
  Uint8List _source;
  RawWriter _destination;

  WriteUint8ListBenchmark(this.destinationIndex, this.sourceIndex, this.length)
      : super(
          "writeUint8List(...): $times times: destinationIndex=$destinationIndex sourceIndex=$sourceIndex length=$length",
        );

  @override
  void setup() {
    _source = new Uint8List(sourceIndex + length);
    for (var i = 0; i < _source.length; i++) {
      _source[i] = i % 256;
    }
    _destination =
        new RawWriter.withCapacity(destinationIndex + times * length);
    super.setup();
  }

  @override
  void run() {
    // Set initial index
    _destination.length = destinationIndex;

    for (var i = 0; i < times; i++) {
      // Copy from source to destination
      _destination.writeBytes(_source, sourceIndex, length);
    }
  }
}
