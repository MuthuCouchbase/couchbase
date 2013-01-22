import java.io.IOException;
public class HeapSort {
    public static void main(String args[]) throws IOException {
       int [] array = {1,4,2,8,5,9,6};
       System.out.println("\n  UnSorted array\n---------------\n");
       for(int i=0;i<array.length;i++) {
           System.out.println("The array is "+array[i]);
       }
       for(int i=array.length;i > 1;i--) {
          heapSort(array, i-1);
       }
       System.out.println("\n  Sorted array\n---------------\n");
       for (int i = 0; i < array.length; i++) {
           System.out.print(" "+array[i]);
       }

    }
    public static void heapSort(int [] arr, int arrBound) {
        int left,right,root,temp, mchild;
        root = (arrBound-1)/2;
        for(int o=root;o>=0;o--) {
            for(int i=root;i>=0;i--) {
                left  = (2*i)+1;
                right = (2*i)+2;
                if(left <= arrBound && right <= arrBound) {
                    if(arr[right] >= arr[left]) {
                        mchild = right;
                    }
                    else {
                        mchild = left;
                    }
                }
                else {
                    if(left > arrBound) {
                        mchild = right;
                    }
                    else {
                        mchild = left;
                    }
                }
                if(arr[i] < arr[mchild]) {
                    temp = arr[mchild];
                    arr[mchild]= arr[i];
                    arr[i] = temp;
                }    
            }
        }
        temp = arr[0];
        arr[0] = arr[arrBound];
        arr[arrBound] = temp;
        return;
    }
}
