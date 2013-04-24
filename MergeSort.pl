#!/usr/bin/perl
use strict;
use warnings;
my @array = (10,15,6,9,21,34,1,3,4);
print "The array is i".shift(@array)."\n";
my $length = scalar(@array);

mergeSort(\@array, $length);
sub mergeSort {
   my($arr, $len) = @_;
   if($len <=1) {
      return @$arr->[0];
   }
   my (@left_array,@right_array)=();
   my $middle = int($len/2);
   for(my $i=0;$i<$middle;$i++) {
      push(@left_array,@$arr[$i]);
   }
   for(my $i=$middle;$i<$len-1;$i++) {
      push(@right_array,@$arr[$i]);
   }
   mergeSort(\@left_array,$middle);
   mergeSort(\@right_array,$middle+1);
   merge(\@left_array, \@right_array);
}
sub merge {
   my($left,$right) =@_;
   my @result;
   while(scalar(@$left) > 0 || scalar(@$right) > 0) {
      if(scalar(@$left) > 0 && scalar(@$right) > 0) {
         if($left->[0] < $right->[0]) {
            push(@result, $left->[0]);
            shift(@$left);
         } else {
            push(@result, $right->[0]);
            shift(@$right);
         }
      }
      elsif(scalar(@$left) > 0) {
         push(@result, $left->[0]);
            shift(@$left);
      }
      elsif(scalar(@$right) > 0) {
         push(@result, $right->[0]);
            shift(@$right);
      }
   }
   return @result;
}
