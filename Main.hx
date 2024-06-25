import BoringSynth.VCO;
import BoringSynth.Saw;
import BoringSynth.Square;
import BoringSynth.DAC;
import BoringSynth.MatrixMixer;
import BoringSynth.IComponent;
import BoringSynth.Value;

class Main {
    static function main() {
        var sampleRate = 44100;

        var value = new Value(440.0, "Value440"); // Frequency value
        var vco = new Saw(sampleRate, "SAW1");
        var dac = new DAC("DAC1");
        var components:Array<IComponent> = [value, vco, dac];

        var matrixMixer = new MatrixMixer(components);

        // Connect the Value output to VCO frequency input
        matrixMixer.setWeight(0, 0, 1.0); // Value left output to VCO input

        // Ensure VCO outputs are connected to DAC inputs
        matrixMixer.setWeight(2, 1, 1.0); // VCO left output to DAC left input
        matrixMixer.setWeight(3, 2, 1.0); // VCO right output to DAC right input

        matrixMixer.printInputOutputTable();

        for (i in 0...10) { // Just run 10 iterations for testing
            matrixMixer.process();
            trace(vco.getName() + " Input: " + vco.getInput(0));
            trace(vco.getOutputName(0) + ": " + vco.getOutput(0));
            trace(vco.getOutputName(1) + ": " + vco.getOutput(1));
            trace(dac.getInputName(0) + ": " + dac.getInput(0));
            trace(dac.getInputName(1) + ": " + dac.getInput(1));
        }
    }
}

