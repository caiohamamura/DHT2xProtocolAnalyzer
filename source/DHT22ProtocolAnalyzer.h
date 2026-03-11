#ifndef DHT22PROTOCOL_ANALYZER_H
#define DHT22PROTOCOL_ANALYZER_H

#include <Analyzer.h>
#include "DHT22ProtocolAnalyzerResults.h"
#include "DHT22ProtocolSimulationDataGenerator.h"

enum DHT2xFrameType {
	SYNC = 1,
	TEMPERATURE,
	RELATIVEHUMIDITY,
	CHECKSUM
};

class DHT22ProtocolAnalyzerSettings;
class ANALYZER_EXPORT DHT22ProtocolAnalyzer : public Analyzer2
{
public:
	DHT22ProtocolAnalyzer();
	virtual ~DHT22ProtocolAnalyzer();
	virtual void WorkerThread();
	virtual void SetupResults();

	virtual U32 GenerateSimulationData( U64 newest_sample_requested, U32 sample_rate, SimulationChannelDescriptor** simulation_channels );
	virtual U32 GetMinimumSampleRateHz();

	virtual const char* GetAnalyzerName() const;
	virtual bool NeedsRerun();

protected: //vars
	std::unique_ptr< DHT22ProtocolAnalyzerSettings > mSettings;
	std::unique_ptr< DHT22ProtocolAnalyzerResults > mResults;
	AnalyzerChannelData* mOneWire;

	DHT22ProtocolSimulationDataGenerator mSimulationDataGenerator;
	bool mSimulationInitilized;

	//OneWire analysis vars:
	U32 mSampleRateHz;
	U32 mStartOfStopBitOffset;
	U32 mEndOfStopBitOffset;
};

extern "C" ANALYZER_EXPORT const char* __cdecl GetAnalyzerName();
extern "C" ANALYZER_EXPORT Analyzer* __cdecl CreateAnalyzer( );
extern "C" ANALYZER_EXPORT void __cdecl DestroyAnalyzer( Analyzer* analyzer );

#endif //DHT22PROTOCOL_ANALYZER_H
