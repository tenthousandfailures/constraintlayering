
package layer;

    typedef enum {READ, WRITE} rw_t;
    
class addr_txn;
    rand bit [31:0] addr;
    rand int size;

    constraint c_size { size inside {1,2,4}; }
endclass
    
class rw_txn extends addr_txn;
    rand rw_t op;

    function void rprint();
        this.randomize();
        this.print();        
    endfunction

    function void print();
        $display("  addr=%h size=%0d", this.addr, this.size);
    endfunction
    
endclass

class rw_constrained_txn extends rw_txn;

    constraint c_addr_valid {
        // Transaction addr range must fit within certain ranges
        addr inside {['h00000000 : 'h0000FFFF - size]} ||
        addr inside {['h10000000 : 'h1FFFFFFF - size]};
        
        
        // Transaction addr range must fit within certain ranges
        // transaction must avoid "magic" testbench control addresses
        !(addr inside {['h00000000 : 'h00000FFF - size]});

        // Don't write to the first 4k bytes. Reads OK.
        if (op==WRITE) {
            !(addr inside {['h00000000 : 'h00000FFF - size]});
        }
    }
    
endclass
    
endpackage    

module TB ();

    import layer::*;
    
    layer::rw_txn rw_txn;
    layer::rw_constrained_txn rw_constrained_txn;
    
    initial begin
        rw_txn = new;
        rw_constrained_txn = new;
        
        $display("\nFIGURE 1. Address transaction base class and derived read/write transaction:");
        for (int i = 0; i < 5; i++) begin
            rw_txn.rprint();
        end

        $display("\nFIGURE 2. Read/write transaction wth address constraints in derived class:");
        for (int i = 0; i < 5; i++) begin
            rw_constrained_txn.rprint();
        end

        $display("\nFIGURE 3. Randomizing read/write transaction using inline constraints:");
        for (int i = 0; i < 5; i++) begin        
            rw_txn.randomize with {
                
                // Transaction addr range must fit within certain ranges
                addr inside {['h00000000 : 'h0000FFFF - size]} ||
                     addr inside {['h10000000 : 'h1FFFFFFF - size]};
                                
                // Transaction addr range must fit within certain ranges
                // transaction must avoid "magic" testbench control addresses
                !(addr inside {['h00000000 : 'h00000FFF - size]});

                // Don't write to first 4k bytes. Reads OK.
                if (op==WRITE) {
                    !(addr inside {['h00000000 : 'h00000FFF - size]});
                }
            };

            rw_txn.print();
            
        end
        
    end
   
endmodule
