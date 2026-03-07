 // We need to convert the 12 bit value into an 8 bit BYTE, the SPI can't write 12bits
   
   //We figure out where in all of the bytes to write to, so we don't have to waste time
   // updating everything
   
   //12 bits into bytes, a start of 12 bits will either at 0 or 4 in a byte
    spibit=0;
    if(bitRead(channel, 0))//if the read of the value is ODD, the start is at a 4
    spibit=4;
    
    //This is a simplification of channel * 12 bits / 8 bits
    spibyte = int(channel*3/2);//this assignes which byte the 12 bit value starts in
  
    for(chbit=0; chbit<12; chbit++, spibit++){// start right at where the update will go
      if(spibit==8){//during the 12 bit cycle, the limit of byte will be reached
      spibyte++;//roll into the next byte
      spibit=0;//reset the bit count in the byte
      }
    if(bitRead(value, chbit))//check the value for 1's and 0's
    bitSet(transferbyte[spibyte], spibit);//transferbyte is what is written to the TLC
    else
    bitClear(transferbyte[spibyte], spibit);
    }//0-12 bit loop
  }//  END OF TLC WRITE  END OF TLC WRITE  END OF TLC WRITE  END OF TLC WRITE  END OF TLC WRITE
