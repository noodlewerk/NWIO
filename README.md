
NWIO
================================

*NWIO is a framework for processing binary data in small chunks. It provides classes for reading, writing, and transforming these chunks. But also high level functions that abstract these chunky details away, allowing you to deal with data as if it were a single blob.*


### Introduction
Processing data in Cocoa is generally done in a single operation on the complete data object, for example using an NSURL or NSData object. Computing for example the SHA1 checksum of a file typically goes like this:

    NSData *data = [NSData dataWithContentsOfURL:fileURL];   
    unsigned char *checksum = CC_SHA1([data bytes], [data length], malloc(CC_SHA1_DIGEST_LENGTH));

With sufficient memory available, this is an efficient approach to most data processing tasks. However it does demand the amount of memory available to be proportional to the size of the data. When this becomes a problem there are several approaches to mitigate this need for memory, for example by using memory mapping from a file. These however do not provide a general solution for scale.

A more scalable solution is to process the data not as a whole, but in separate chunks of data. This however requires a bit more care, as chunks have to be glued together. NWIO is an extensible framework that provides a basis for building custom operations, as well as implementations for a lot of common tasks. For example, computing the checksum using NWIO goes like this:

    NWIODigestStream *digester = [[NWIODigestStream alloc] initWithInputURL:fileURL];
    [digester drainFromSource];
    unsigned char *checksum = [[digester inputDigest] bytes];

Instead of reading all data in a single line of code, NWIO typically splits this into a declaration and an execution line. The first line sets up the stream, a digesting stream in this case. The second pulls all data from the file through this stream, allowing it to compute the file's digest.


### Features
+ *On-the-fly processing of data.* Because data is processed in chunks, operations do not have to wait until the last byte arrives before it can start processing. This makes streaming data much mo, for example parsing data while it's download from the web.
+ *With generic classes that represent access data, instead of the data itself.* A bit like NSURL does, but then including data that does not have a resource locator. And with more control over how this data can be accessed, i.e. stream or direct.
+ *Connects to a variety of other data access classes.* Including NSStream, CGDataProvider, and OpenSSL BIO.
+ *Focus on ease of use.* Easy to get started, requiring little configuration and running gracefully no matter what you feed it.
+ *100% Objective-C.*

But..

- It's still experimental, more exposure to tests and practice needed.
- It doesn't do any fancy multi-threading, thread safe locking, or scheduling on a runloop.
- It's Objective-C, so no highly optimized C nor assembly.


### Getting started
- Read a bit about the design in this readme, just to get the basics concepts that constitute NWIO. What is the difference between NWIOStream and NWIOAccess?
- Download the XCode project and run the Demo app. Take a look at the code behind a demo and see if you can modify it toward your need.
- Add the classes you need to your project. You probably need all files from the 'Core' folder, and a few task-specific ones from 'Sources', 'Filters', 'Transforms', or 'Extracts'.
- Take a look at the debug facilities available, like NWIOLog, NWIOProgress, and NWIOStat.


### Design
The design of NWIO was based on a variety of stream implementations, including NSStream, Java streams, and OpenSSL BIO.


#### Classes
NWIO has a modular design, allowing cherry picking functionality. It has a set of core classes that represent abstract operation types like sources, filters, transforms, and extracts. With each of these abstract operations comes a folder with a variety of implementations.

- *Source* is the begin of a stream, connecting to other data sources like NSData, NSString, and NSStream.
- *Filter* is a link in a chain of operations, allowing a series of operations to be performed on a source.
- *Transforms* is a filter that manipulates the the data coming though, for example NWIODeflat that inflates on read and deflates on write.
- *Extact* is a filter that observes the data coming though, for example a NSIODigester that computes the SHA hash.

Next to these operations, there is a set of tools to perform high level operations, like draining a stream. These are generally the starting point in development, thereby skipping the details of stream and access implementations. For example, to unzip a file to data, one should avoid calling [read:length:] repeatedly, but instead call [drain]:

    NWIODeflateStream *deflater = [[NWIODeflateStream alloc] initWithInputURL:fileURL];
    NSData *deflated = [deflater drainFromInputToDataBuffered:YES];


#### Chunk order
NIWO offers both sequential streaming and direct access variants of most operations. Sequential streaming is often most efficient for processing data from begin to end, similar to NSInputStream and NSOutputStream. In NWIO all sequential operations inherit from the NWIOStream class.

Direct access on the other hand, operates only on a given range of the data, allowing specific parts to be processed. This is similar to NSData, but without having access to a single pointer of all data. All direct operations inherit from the NWIOAccess class.


#### Memory allocation
All reading and writing operations come in two flavors: active and passive. Active reading takes an array as input and fills it with read data, while passive reading returns an array with read data. Similarly, active writing takes an array of data to write, while passive writing returns an array in which you can write your data directly.

The distinction between active and passive exists for performance reasons. Active operations are used when an array of data has already been allocated and only needs processing, e.g. written to disk. This leaves the decision whether to copy this array or process it directly to the callee.

When implementing a subclass of NSStream or NSAccess, you only need to implement one of both. Internally, both stream and access will internally convert between active and passive where needed.


#### Extending to your need
Currently all implementations of the abstract core operations allow for little configuration. Therefore it is likely that what you're looking for is not directly available in NWIO. Instead of things being endlessly configurable, they are easily extensible. So choose an operation similar to you need and modify it accordingly. For example, to count the occurence of a character, simple extend NWIOExtract and implement:

    - (void)extractFrom:(const unsigned char *)buffer length:(NSUInteger)length {
        while (length--) {
            if (*(buffer++) == 'x') {
                count++;
            }
        }
    }


#### Coding style
- Things should always work, and do the most 'common' task, no more complicated than needed.
- Optimization should be done on a high level, for example by changing the composition of the chain.
- Every buffer (void *) can be zero, which indicates a transparent buffer.
- Never assume a buffer to not be NULL, never treat NULL as an error.
- Respect the expected complexity of methods. A single io call typically results in a single chain of subsequent io calls along the stream.


#### Read for a read
IO operations should have execution time proportional to the complexity of the operation itself and composition based on other IO operations. One should avoid for example implementing a read operation that cascades into a series of reads in order to fill a given buffer. Such compensating behavior hides inefficiencies and it is difficult to guarantee successful operation in general. If stream fragmentation in underlying streams cause performance loss, one should insert a buffering stream to compensate.


### FAQ

*Why do you use 'read' and 'input' interchangeably?* Initially it was only 'read', but that made some things confusing. So I chose to use read/write for operations and actions, while input/output refers to actual objects and relations.

*Why did you put the reader and the writer in the same class?* There's not so much reason as style involved here. I mostly wanted to keep the number of classes and methods small. It should benefit the simplicity and ease-of-use; hope it did.

*Don't you think there it is much more efficient to write a custom stream instead of using NWIO?* There surely is. NWIO wasn't built with a performance focus. Perfectly balanced buffers could deliver a significant performance gain, but will be harder to write, debug, and maintain. Also, there is quite some room for tweaking NWIO's performance, for example by setting buffer sizes and ordering streams.


### Build in XCode
The source comes with an XCode 4 project file that should take care of building the library and running the demo app. To use NWIO in your project, it is recommended to directly include those source files needed. This does however require the LLVM 3.0 compiler with ARC.


### Documentation
Documentation generated and installed by running from the project root:

`appledoc -p NWIO -v 0.1 -c Noodlewerk --company-id com.noodlewerk -o . .`

See the [appledoc documentation](http://www.gentlebytes.com/home/appledocapp/) for more info.


### Bugs, flaws, missing features
If you find any bugs, design flaws, or think NWIO is missing a feature, then submit an issue on GitHub. Ideally provide with it a piece of (runnable, bug free) code that exposes the problem. In the case of a bug, this would be a unit test that fails until the bug is fixed. Take a look at NWIOTests folder for examples.


### Plans
On the short term:

- Add NSURLConnection delegate stream
- Implement switching in NWIOAccess
- Fix OpenSSL binding
- Finish implementation NWIOCryptoAccess

In the long run:

- Add many more sources, filters, transforms, and extracts. We will welcome your requests.
- Extend beyond bytes, e.g. to text (UTF8), with a NSScanner-like implementation, or a streaming XML/JSON parser.


### License
NWIO is licensed under the terms of the Apache License version 2.0, see the included LICENSE file.


### Authors
- [Noodlewerk](http://www.noodlewerk.com/)
- [Leonard van Driel](http://www.leonardvandriel.nl/)

